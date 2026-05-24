# 📚 Squirrel Development Guides
**Location**: `docs/guides/`  
**Purpose**: Comprehensive guides for development patterns and migrations

---

## 🦀 **Rust Pattern Guides**

### **Error Handling**:
- **[MODERN_ERROR_PATTERNS_GUIDE.md](MODERN_ERROR_PATTERNS_GUIDE.md)** ⭐
  - Modern idiomatic Rust error handling
  - Before/after examples
  - Best practices and anti-patterns
  - Testing strategies
  - Created: Nov 9, 2025

---

## 🔄 **Migration Guides**

### **AI Tools Error Migration**:
- **[AI_TOOLS_ERROR_MIGRATION_TRACKER.md](AI_TOOLS_ERROR_MIGRATION_TRACKER.md)**
  - Complete migration tracking
  - File-by-file progress
  - Pattern documentation
  - Lessons learned
  - Completed: Nov 9, 2025

### **Config System Migration**:
- See `docs/migration/CONFIG_MIGRATION_GUIDE.md`
  - Four systems → one unified system
  - Type mappings
  - Migration checklist
  - Troubleshooting

---

## 🎯 **How to Use These Guides**

### **For New Features**:
1. Check existing patterns first
2. Follow modern Rust patterns (see MODERN_ERROR_PATTERNS_GUIDE.md)
3. Use unified systems (error, config, constants)
4. Document new patterns

### **For Migrations**:
1. Read relevant migration guide
2. Follow systematic approach
3. Test after each change
4. Update tracker documents

### **For Code Reviews**:
- Reference these guides for standards
- Ensure modern patterns used
- Check unified system usage
- Verify documentation

---

## 📝 **Adding New Guides**

### **When to Create a Guide**:
- New pattern established
- Migration completed
- Best practices identified
- Common pitfalls documented

### **Guide Template**:
```markdown
# [Topic] Guide
**Date**: YYYY-MM-DD
**Status**: Active/Archived
**Applies To**: [What this covers]

## Overview
[Brief description]

## Patterns
[Documented patterns with examples]

## Examples
[Before/After examples]

## Common Issues
[Troubleshooting]

## References
[Related docs]
```

---

## 🔗 **Related Documentation**

- **[ROOT_DOCS_INDEX.md](../../ROOT_DOCS_INDEX.md)** - Main doc index
- **[docs/sessions/](../sessions/)** - Session notes
- **[docs/migration/](../migration/)** - Migration docs
- **[docs/adr/](../adr/)** - Architecture decisions

---

**Last Updated**: November 9, 2025  
**Guide Count**: 2 (Error patterns, AI tools migration)  
**Status**: ✅ Active  

🐿️ **Follow these guides for world-class Rust code!** 🦀

