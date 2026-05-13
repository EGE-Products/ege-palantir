// Palantír nav-extension — the SOLE seam between Palantír and upstream
// ui-v2. Additive-only discipline: every other file under
// ui-v2/src/palantir/ is freely editable and conflict-free during weekly
// upstream rebases. This file is the one allowed integration point, and
// even here the contract is one-way — `app-sidebar.tsx` (upstream) imports
// from this module; this module never imports app-sidebar internals.
//
// Implementation lands in EGE-209: export an array of sidebar entries
// (label, href, icon) that app-sidebar.tsx splices into its nav group.
// Until then this is an empty placeholder so the build stays green.

export const palantirNavExtension: readonly never[] = [];
