(() => {
  'use strict';

  const state = {
    appMount: crypto.randomUUID(),
    pageMount: 1,
    page: 'home',
    counter: 0,
    sequence: 0,
    events: [],
    maxEvents: 4,
    installed: false,
    cancellationStarted: false,
    cancellationSignalProvided: false,
    cancellationObserved: false,
    cancellationCompleted: false,
    cancellationSideEffects: 0,
  };

  const results = [];
  window.__gateResults = results;
  window.__gateDone = false;
  window.__fixtureState = state;

  function recordEvent(kind) {
    state.sequence += 1;
    state.events.push({ sequence: state.sequence, kind });
    if (state.events.length > state.maxEvents) {
      state.events.shift();
    }
  }

  function cursor() {
    return `${state.appMount}:${state.sequence}`;
  }

  function observe(input = {}) {
    const waitMs = input.waitMs ?? 0;
    if (!Number.isInteger(waitMs) || waitMs < 0 || waitMs > 1000) {
      return { ok: false, error: { code: 'invalidArguments' } };
    }
    if (waitMs > 0) {
      return {
        ok: false,
        error: { code: 'unsupportedWait' },
        capabilities: { immediatePolling: true, positiveWait: false },
      };
    }

    let gap = false;
    let refreshRequired = false;
    let since = 0;
    if (input.cursor != null) {
      const parts = String(input.cursor).split(':');
      const cursorSequence = Number(parts.at(-1));
      const cursorMount = parts.slice(0, -1).join(':');
      const oldest = state.events[0]?.sequence ?? state.sequence;
      if (
        cursorMount !== state.appMount ||
        !Number.isInteger(cursorSequence) ||
        cursorSequence < oldest - 1 ||
        cursorSequence > state.sequence
      ) {
        gap = true;
        refreshRequired = true;
      } else {
        since = cursorSequence;
      }
    }

    return {
      ok: true,
      appCursor: cursor(),
      gap,
      refreshRequired,
      active: [
        {
          ref: `scope-${state.pageMount}`,
          page: state.page,
          mount: state.pageMount,
        },
      ],
      events: gap
        ? []
        : state.events
            .filter((event) => event.sequence > since)
            .map(({ sequence, kind }) => ({ sequence, kind })),
      capabilities: { immediatePolling: true, positiveWait: false },
    };
  }

  function toolDefinitions(increment, navigate, remount) {
    return [
      {
        name: 'fixture_cancel',
        description:
          'Waits until completion or agent cancellation; use only to test cancellation.',
        inputSchema: {
          type: 'object',
          properties: { delayMs: { type: 'integer', minimum: 100, maximum: 5000 } },
          required: ['delayMs'],
          additionalProperties: false,
        },
        annotations: {
          readOnlyHint: true,
          untrustedContentHint: false,
          consequentialHint: false,
        },
        execute: ({ delayMs }, executionContext) => {
          state.cancellationStarted = true;
          const signal =
            executionContext?.signal ??
            (executionContext instanceof AbortSignal ? executionContext : null);
          state.cancellationSignalProvided = signal instanceof AbortSignal;
          return new Promise((resolve, reject) => {
            const timer = setTimeout(() => {
              state.cancellationCompleted = true;
              state.cancellationSideEffects += 1;
              resolve({ ok: true, completed: true });
            }, delayMs);
            signal?.addEventListener(
              'abort',
              () => {
                state.cancellationObserved = true;
                clearTimeout(timer);
                reject(new DOMException('Cancelled', 'AbortError'));
              },
              { once: true },
            );
          });
        },
      },
      {
        name: 'fixture_increment',
        description:
          'Increment the visible synthetic counter once and return bounded effect evidence.',
        inputSchema: {
          type: 'object',
          properties: {},
          additionalProperties: false,
        },
        annotations: {
          readOnlyHint: false,
          untrustedContentHint: false,
          consequentialHint: false,
        },
        execute: () => {
          state.counter = Number(increment());
          recordEvent('visibleEffectObserved');
          return { ok: true, counter: state.counter, evidence: 'visibleEffectObserved' };
        },
      },
      {
        name: 'fixture_navigate',
        description:
          'Navigate the synthetic app to details and return an app-owned dispatch receipt.',
        inputSchema: {
          type: 'object',
          properties: {
            destination: { type: 'string', enum: ['home', 'details'] },
          },
          required: ['destination'],
          additionalProperties: false,
        },
        annotations: {
          readOnlyHint: false,
          untrustedContentHint: false,
          consequentialHint: false,
        },
        execute: ({ destination }) => {
          const admittedMount = state.pageMount;
          state.page = String(navigate(destination));
          state.pageMount += 1;
          recordEvent('commandDispatched');
          return {
            ok: true,
            receipt: {
              status: 'commandDispatched',
              admittedMount,
              currentMount: state.pageMount,
            },
          };
        },
      },
      {
        name: 'fixture_observe',
        description:
          'Observe current synthetic app metadata. Always call with waitMs 0 for immediate polling.',
        inputSchema: {
          type: 'object',
          properties: {
            cursor: { type: 'string' },
            waitMs: { type: 'integer', minimum: 0, maximum: 1000 },
          },
          additionalProperties: false,
        },
        annotations: {
          readOnlyHint: true,
          untrustedContentHint: false,
          consequentialHint: false,
        },
        execute: observe,
      },
      {
        name: 'fixture_remount',
        description:
          'Remount the current synthetic page and emit bounded events for cursor-gap testing.',
        inputSchema: {
          type: 'object',
          properties: {},
          additionalProperties: false,
        },
        annotations: {
          readOnlyHint: false,
          untrustedContentHint: false,
          consequentialHint: false,
        },
        execute: () => {
          state.pageMount = Number(remount());
          for (let index = 0; index < state.maxEvents + 1; index += 1) {
            recordEvent('scopeChanged');
          }
          return { ok: true, mount: state.pageMount };
        },
      },
      {
        name: 'fixture_safe_error',
        description: 'Return a sanitized synthetic failure without secrets, stacks, or raw errors.',
        inputSchema: {
          type: 'object',
          properties: {},
          additionalProperties: false,
        },
        annotations: {
          readOnlyHint: true,
          untrustedContentHint: false,
          consequentialHint: false,
        },
        execute: () => ({
          ok: false,
          error: { code: 'syntheticFailure', retryable: false },
        }),
      },
      {
        name: 'fixture_safe_result',
        description: 'Return a bounded JSON-safe synthetic result.',
        inputSchema: {
          type: 'object',
          properties: {},
          additionalProperties: false,
        },
        annotations: {
          readOnlyHint: true,
          untrustedContentHint: false,
          consequentialHint: false,
        },
        execute: () => ({
          ok: true,
          values: ['alpha', 7, true, null],
          nonFiniteValue: null,
        }),
      },
    ];
  }

  function addResult(name, verdict, detail) {
    const result = { name, verdict, detail };
    results.push(result);
    console.log(`EVIDENCE|${name}|${verdict}|${detail}`);
    render();
  }

  function render() {
    let panel = document.getElementById('evidence');
    if (!panel) {
      panel = document.createElement('pre');
      panel.id = 'evidence';
      panel.style.cssText =
        'position:fixed;z-index:10000;left:8px;bottom:8px;width:min(760px,95vw);' +
        'max-height:44vh;overflow:auto;background:#111;color:#eee;padding:12px;' +
        'font:12px monospace;border-radius:6px;white-space:pre-wrap';
      document.body.appendChild(panel);
    }
    panel.textContent = results
      .map(({ name, verdict, detail }) => `${name}: ${verdict} — ${detail}`)
      .join('\n');
  }

  async function execute(name, input, options) {
    const tools = await document.modelContext.getTools();
    const tool = tools.find((candidate) => candidate.name === name);
    if (!tool) throw new Error(`Missing tool: ${name}`);
    const result = await document.modelContext.executeTool(
      tool,
      JSON.stringify(input),
      options,
    );
    return decodeResult(result);
  }

  function decodeResult(result) {
    if (typeof result !== 'string') return result;
    try {
      return JSON.parse(result);
    } catch (_) {
      return result;
    }
  }

  async function pollUntil(predicate, timeoutMs, intervalMs = 10) {
    const deadline = performance.now() + timeoutMs;
    while (performance.now() < deadline) {
      if (predicate()) return true;
      await new Promise((resolve) => setTimeout(resolve, intervalMs));
    }
    return predicate();
  }

  async function settleWithin(promise, timeoutMs) {
    return Promise.race([
      promise.then(
        (value) => ({ settled: true, fulfilled: true, value }),
        (error) => ({
          settled: true,
          fulfilled: false,
          error: `${error?.name}: ${error?.message}`,
        }),
      ),
      new Promise((resolve) =>
        setTimeout(() => resolve({ settled: false, fulfilled: false }), timeoutMs),
      ),
    ]);
  }

  function resetCancellationState() {
    state.cancellationStarted = false;
    state.cancellationSignalProvided = false;
    state.cancellationObserved = false;
    state.cancellationCompleted = false;
    state.cancellationSideEffects = 0;
  }

  async function runConformance() {
    try {
      const modelContext = document.modelContext;
      const functional =
        window.isSecureContext &&
        window.crossOriginIsolated &&
        modelContext &&
        typeof modelContext.registerTool === 'function' &&
        typeof modelContext.getTools === 'function' &&
        typeof modelContext.executeTool === 'function';
      addResult(
        'secure-functional-surface',
        functional ? 'PASS' : 'FAIL',
        `secure=${window.isSecureContext} isolated=${window.crossOriginIsolated}`,
      );
      if (!functional) return;

      const tools = await modelContext.getTools();
      const fixtureTools = tools.filter((tool) => tool.name.startsWith('fixture_'));
      const names = fixtureTools.map((tool) => tool.name);
      const sorted = [...names].sort();
      const observeTool = fixtureTools.find((tool) => tool.name === 'fixture_observe');
      const origins = [...new Set(fixtureTools.map((tool) => tool.origin))];
      const originPass =
        window.crossOriginIsolated &&
        origins.length === 1 &&
        origins[0] === window.location.origin;
      addResult(
        'origin-isolation',
        originPass ? 'PASS' : 'FAIL',
        `page=${window.location.origin} tools=${JSON.stringify(origins)}`,
      );
      const schema =
        typeof observeTool.inputSchema === 'string'
          ? JSON.parse(observeTool.inputSchema)
          : observeTool.inputSchema;
      const registrationPass =
        names.length === 7 &&
        JSON.stringify(names) === JSON.stringify(sorted) &&
        schema.properties.waitMs.maximum === 1000;
      addResult(
        'registration-gettools',
        registrationPass ? 'PASS' : 'FAIL',
        `count=${names.length} sorted=${JSON.stringify(names) === JSON.stringify(sorted)}`,
      );

      const annotations = observeTool.annotations;
      const annotationsPass =
        annotations.readOnlyHint === true &&
        annotations.untrustedContentHint !== true &&
        annotations.consequentialHint !== true;
      addResult(
        'annotations',
        annotationsPass ? 'PASS' : 'FAIL',
        JSON.stringify(annotations),
      );

      const incrementResult = await execute('fixture_increment', {});
      addResult(
        'execute-json-string',
        incrementResult?.ok && incrementResult.counter === 1 ? 'PASS' : 'FAIL',
        JSON.stringify(incrementResult),
      );

      let invalidRejected = false;
      try {
        await modelContext.executeTool(
          fixtureTools.find((tool) => tool.name === 'fixture_increment'),
          '{not-json',
        );
      } catch (error) {
        invalidRejected = true;
      }
      addResult(
        'invalid-input-no-dispatch',
        invalidRejected && state.counter === 1 ? 'PASS' : 'FAIL',
        `rejected=${invalidRejected} counter=${state.counter}`,
      );

      const safeResult = await execute('fixture_safe_result', {});
      const safeError = await execute('fixture_safe_error', {});
      const safeSerialized = JSON.stringify({ safeResult, safeError });
      const safetyPass =
        safeResult?.nonFiniteValue === null &&
        safeError?.error?.code === 'syntheticFailure' &&
        !safeSerialized.includes('stack') &&
        !safeSerialized.includes('secret');
      addResult('safe-results-errors', safetyPass ? 'PASS' : 'FAIL', safeSerialized);

      resetCancellationState();
      const cancellationDelayMs = 600;
      const cancellationController = new AbortController();
      const cancellation = execute(
        'fixture_cancel',
        { delayMs: cancellationDelayMs },
        { signal: cancellationController.signal },
      );
      const cancellationStarted = await pollUntil(
        () => state.cancellationStarted,
        2000,
      );
      if (cancellationStarted) cancellationController.abort();
      const cancellationSettlement = await settleWithin(cancellation, 2000);
      if (cancellationStarted) {
        await new Promise((resolve) =>
          setTimeout(resolve, cancellationDelayMs + 300),
        );
      }
      const cancellationPass =
        cancellationStarted &&
        state.cancellationSignalProvided === true &&
        state.cancellationObserved === true &&
        state.cancellationCompleted === false &&
        state.cancellationSideEffects === 0;
      addResult(
        'execute-cancellation-after-start',
        cancellationPass ? 'PASS' : 'FAIL',
        `started=${cancellationStarted} signalProvided=${state.cancellationSignalProvided} ` +
          `signalObserved=${state.cancellationObserved} ` +
          `completed=${state.cancellationCompleted} sideEffects=${state.cancellationSideEffects} ` +
          `settlement=${JSON.stringify(cancellationSettlement)}`,
      );

      resetCancellationState();
      const beforeDispatchController = new AbortController();
      beforeDispatchController.abort();
      const beforeDispatchSettlement = await settleWithin(
        execute(
          'fixture_cancel',
          { delayMs: cancellationDelayMs },
          { signal: beforeDispatchController.signal },
        ),
        1000,
      );
      await new Promise((resolve) =>
        setTimeout(resolve, cancellationDelayMs + 300),
      );
      const beforeDispatchPass =
        state.cancellationStarted === false &&
        state.cancellationSignalProvided === false &&
        state.cancellationObserved === false &&
        state.cancellationCompleted === false &&
        state.cancellationSideEffects === 0;
      addResult(
        'cancel-before-dispatch',
        beforeDispatchPass ? 'PASS' : 'FAIL',
        `started=${state.cancellationStarted} signalProvided=${state.cancellationSignalProvided} ` +
          `signalObserved=${state.cancellationObserved} ` +
          `completed=${state.cancellationCompleted} sideEffects=${state.cancellationSideEffects} ` +
          `settlement=${JSON.stringify(beforeDispatchSettlement)}`,
      );

      const unregisterController = new AbortController();
      await modelContext.registerTool(
        {
          name: 'fixture_temporary',
          description: 'Temporary registration used only for lifecycle proof.',
          inputSchema: { type: 'object', properties: {} },
          execute: () => ({ ok: true }),
        },
        { signal: unregisterController.signal },
      );
      const presentBeforeAbort = (await modelContext.getTools()).some(
        (tool) => tool.name === 'fixture_temporary',
      );
      unregisterController.abort();
      await new Promise((resolve) => setTimeout(resolve, 0));
      const presentAfterAbort = (await modelContext.getTools()).some(
        (tool) => tool.name === 'fixture_temporary',
      );
      addResult(
        'abortsignal-unregistration',
        presentBeforeAbort && !presentAfterAbort ? 'PASS' : 'FAIL',
        `before=${presentBeforeAbort} after=${presentAfterAbort}`,
      );

      const firstObserve = await execute('fixture_observe', { waitMs: 0 });
      const unsupportedWait = await execute('fixture_observe', { waitMs: 1 });
      const immediatePass =
        firstObserve?.ok &&
        firstObserve.capabilities.immediatePolling === true &&
        unsupportedWait?.error?.code === 'unsupportedWait';
      addResult(
        'observe-immediate-polling',
        immediatePass ? 'PASS' : 'FAIL',
        JSON.stringify({ firstObserve, unsupportedWait }),
      );

      await execute('fixture_remount', {});
      const gapObserve = await execute('fixture_observe', {
        waitMs: 0,
        cursor: firstObserve.appCursor,
      });
      addResult(
        'cursor-gap-remount',
        gapObserve?.gap && gapObserve.refreshRequired ? 'PASS' : 'FAIL',
        JSON.stringify(gapObserve),
      );

      const navigation = await execute('fixture_navigate', { destination: 'details' });
      const afterNavigation = await execute('fixture_observe', { waitMs: 0 });
      const navigationPass =
        navigation?.receipt?.status === 'commandDispatched' &&
        navigation.receipt.currentMount > navigation.receipt.admittedMount &&
        afterNavigation.active[0].page === 'details';
      addResult(
        'navigation-receipt-observe',
        navigationPass ? 'PASS' : 'FAIL',
        JSON.stringify({ navigation, afterNavigation }),
      );
    } catch (error) {
      addResult('conformance-runner', 'FAIL', `${error?.name}: ${error?.message}`);
    } finally {
      window.__gateDone = true;
      render();
    }
  }

  window.installWebMcpFixture = async (increment, navigate, remount) => {
    if (state.installed) return;
    state.installed = true;
    if (!document.modelContext) {
      addResult('registration', 'FAIL', 'document.modelContext is absent');
      window.__gateDone = true;
      return;
    }
    try {
      for (const tool of toolDefinitions(increment, navigate, remount)) {
        await document.modelContext.registerTool(tool);
      }
      recordEvent('scopeMounted');
      await runConformance();
    } catch (error) {
      addResult('registration', 'FAIL', `${error?.name}: ${error?.message}`);
      window.__gateDone = true;
    }
  };
})();
