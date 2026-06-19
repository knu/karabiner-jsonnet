{
  // Escape a literal string for safe use in a regular expression.
  //
  // Jsonnet has no regex-escape builtin, so each character is examined and
  // any ASCII non-word character (other than space) is prefixed with a
  // backslash.  This is broader and safer than enumerating metacharacters
  // one by one.
  escapeRegex(str)::
    std.join('', [
      local c = std.codepoint(ch);
      if (c >= std.codepoint('0') && c <= std.codepoint('9'))
         || (c >= std.codepoint('A') && c <= std.codepoint('Z'))
         || (c >= std.codepoint('a') && c <= std.codepoint('z'))
         || c == std.codepoint('_')
         || c >= 128
      then ch
      else '\\' + ch
      for ch in std.stringChars(str)
    ]),
}
