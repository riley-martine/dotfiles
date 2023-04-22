exports.profanitySureness = 2
exports.noBinary = true

// Honestly a lot of these are not so useful
// I will disable as they come up
// https://github.com/retextjs/retext-equality/blob/main/rules.md
exports.allow = [
    "invalid",
    "dad-mom", // "pop"
    "hook",
    "special",
    "crack",
    "master", // We use this as main branch at work, nothing I can do.
    "execute"
]
