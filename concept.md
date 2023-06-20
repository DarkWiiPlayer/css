# General Design Concepts

## Separation

### Layout

Styles that handle the positioning of elements in relation to each other.

### Components

Styles that change the appearance of the element they are applied to and only
marginally affect their internal or external positioning.

## Selection

### Prefer custom elements for self-contained new functionality

**bad**:

    div.vertical-spacer { /* ... */ }

**better**:

    vertical-spacer { /* ... */ }

### Prefer extension for existing functionality

**bad**:

    primary-button { /* ... */ }

**good**:

    button.primary { /* ... */ }

### Prefer self-descripting names

**bad**:

    v-s { /* ... */ }

**better**:

    vertical-spacer { /* ... */ }

### Prefer classes for optional element re-skinning

**bad**:

    button[warning] { color: red; }

**better**:

    button.warning { color: red; }

### Prefer classes for *primary* type of custom elements

**bad**:

    flex-box[flow="column"] { /* ... */ }

**better**:

    flex-box.column { /* ... */ }

### Prefer classes for a reasonable number of primary type dimensions

**bad**:

    button[danger] { /* ... */ }
    button[floating] { /* ... */ }

**better**:

    button.danger { /* ... */ }
    button.floating { /* ... */ }

### Prefer attributes over repeated classes

**bad**:

    .gap-1 { gap: 1 }
    .gap-2 { gap: 2 }
    .gap-3 { gap: 3 }
    /* etc. */

**better**:

    [gap="1"] { gap: 1 }
    [gap="2"] { gap: 2 }
    [gap="3"] { gap: 3 }
    /* etc. */

## Theming

### Prefer generic custom properties in component styles

**bad**:

    --framework-color: red;
    --button-color: blue;

**good**:

    --color: blue;

### Use themes to override these styles instead

`components/button.css`:
    button { color: var(--color, orange) }

`themes/blue.css`:
    :root { --button-color: blue; }
    button { --color: var(--button-color) }

## Responsive Design

This is still a bit of a question mark 😖

For grid-layouts: `columns=n@1920` seems to work.

For tables, etc. something like `wrap=@500` might work

## Miscellaneous

### Balance DRY and YAGNI

Be lazy in extracting intermediary variables.
Wait until an expression is repeated in three or four places before extracting
it into a separate property.
