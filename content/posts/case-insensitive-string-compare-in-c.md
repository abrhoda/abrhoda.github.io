---
title: "Case Insensitive String Comparison In C"
date: "2025-12-11"
description: "ANSI C case insensitive string comparison of the first n characters in two strings."
toc: false
readTime: false
autonumber: false
math: false
tags: ["c", "snippet"]
hideBackToTop: true
hidePagination: true
showTags: true
---

A simple function to case insensitively compare 2 strings, up to the n chars. This function follows the C standard of returning 0 if the strings are equal, a negative number if the first character that does not match has a lower value in str1 than in str2, or a positive number if the first character that does not match has a greater value in str1 than in str2.

```c
int strncmpci(char const *str1, char const *str2, size_t n) {
  while (n && *str1 &&
         (tolower(*(unsigned char *)str1) == tolower(*(unsigned char *)str2))) {
    str1++;
    str2++;
    n--;
  }
  if (n == 0) {
    return 0;
  } else {
    return (tolower(*(unsigned char *)str1) - tolower(*(unsigned char *)str2));
  }
}
```

