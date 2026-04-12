---
title: "Handling Errors In C"
date: "2026-04-12"
description: "The many fun ways that errors can be handled once they happen."
toc: false
readTime: false
autonumber: false
math: false
tags: ["c"]
hideBackToTop: true
hidePagination: true
showTags: true
---

Handling errors in c

## Ways
### 1: Don't.
Let it crash

### 2: Result Enum Return With Out Param

### 3: Return Value and take an out pointer to error struct (opposite of 2)

### 4: Return a result struct of value and failure like an optional

### 5: use errno

### 6: return sentinel value for type and use an "error queue" (similar to 5)
