# Dark Mode Implementation

## Overview
Complete dark mode integration voor de Uitleenschrift applicatie met automatische theme switching en localStorage persistence.

## Features

### 🎨 Theme Toggle
- **Toggle knop** in de navbar voor zowel ingelogde als niet-ingelogde gebruikers
- **Icoon switching**: Maan icoon (🌙) voor light mode, zon icoon (☀️) voor dark mode
- **Smooth transitions** tussen themes (0.3s ease)

### 💾 Persistence
- **localStorage**: Theme voorkeur wordt opgeslagen in browser
- **Automatic restore**: Theme wordt automatisch hersteld bij page load
- **Cross-session**: Voorkeur blijft behouden tussen browser sessies

### 🎯 Comprehensive Styling
Dark mode ondersteuning voor alle UI elementen:

#### Navigation & Layout
- Navbar met aangepaste dark background
- Footer styling voor dark theme
- Card components met appropriate dark colors

#### Forms & Inputs
- Form controls (input, select, textarea)
- Focus states met consistent styling
- Placeholder text met juiste contrast

#### Interactive Elements
- Buttons (primary, secondary, outline)
- Dropdowns en dropdown items
- Hover states en transitions

#### Data Display
- Tables met dark backgrounds
- Striped table rows
- Badges en labels
- Alert messages

#### Advanced Components
- Modal dialogs
- List groups
- Match cards voor book selection
- Print-friendly layouts

## Technical Implementation

### CSS Variables
```css
:root {
    --bg-color: #ffffff;
    --text-color: #212529;
    --card-bg: #ffffff;
    --border-color: #dee2e6;
    --navbar-bg: var(--bs-primary);
    --match-card-bg: #ffffff;
    --match-card-border: #dee2e6;
    --alert-bg: #d1ecf1;
    --footer-bg: #f8f9fa;
}

[data-bs-theme="dark"] {
    --bg-color: #212529;
    --text-color: #ffffff;
    --card-bg: #343a40;
    --border-color: #495057;
    --navbar-bg: #1a1d20;
    --match-card-bg: #343a40;
    --match-card-border: #495057;
    --alert-bg: #0c4128;
    --footer-bg: #1a1d20;
}
```

### JavaScript Implementation
```javascript
function toggleTheme() {
    const html = document.documentElement;
    const themeIcon = document.getElementById('theme-icon');
    const currentTheme = html.getAttribute('data-bs-theme');
    
    if (currentTheme === 'dark') {
        html.setAttribute('data-bs-theme', 'light');
        themeIcon.className = 'bi bi-moon-fill';
        localStorage.setItem('theme', 'light');
    } else {
        html.setAttribute('data-bs-theme', 'dark');
        themeIcon.className = 'bi bi-sun-fill';
        localStorage.setItem('theme', 'dark');
    }
}

// Initialize theme on page load
document.addEventListener('DOMContentLoaded', function() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    const html = document.documentElement;
    const themeIcon = document.getElementById('theme-icon');
    
    html.setAttribute('data-bs-theme', savedTheme);
    
    if (savedTheme === 'dark') {
        themeIcon.className = 'bi bi-sun-fill';
    } else {
        themeIcon.className = 'bi bi-moon-fill';
    }
});
```

## User Experience

### Accessibility
- **High contrast** kleuren voor betere leesbaarheid
- **Consistent focus indicators** in beide themes
- **Icon feedback** bij theme switching
- **Keyboard accessibility** behouden

### Visual Consistency
- **Bootstrap integration**: Gebruikt Bootstrap's data-bs-theme attribute
- **Color harmony**: Consistent kleurenschema door hele applicatie
- **Smooth transitions**: Geen jarring switches tussen themes

### Performance
- **CSS variables**: Efficient theme switching zonder re-render
- **localStorage**: Minimal overhead voor persistence
- **Progressive enhancement**: Graceful fallback naar light mode

## Files Modified

### templates/base.html
- Added CSS variables voor theme switching
- Enhanced dark mode specific styling
- Added theme toggle button voor alle gebruikers
- Implemented JavaScript voor theme switching
- Added localStorage persistence logic

## Testing

### Browser Compatibility
- ✅ Modern browsers met CSS custom properties support
- ✅ localStorage support (IE8+)
- ✅ Bootstrap 5.3+ dark mode support

### User Scenarios
- ✅ First-time gebruiker (default light mode)
- ✅ Theme switching en persistence
- ✅ Cross-page navigation met consistent theme
- ✅ Authenticated en non-authenticated users

## Future Enhancements

### Possible Additions
- System theme detection (`prefers-color-scheme`)
- Animation improvements
- Theme-specific images/logos
- Print stylesheet considerations

### Maintenance
- Monitor browser compatibility
- Update color variables als design evolueert
- Test nieuwe UI components voor dark mode compatibility

---

**Status**: ✅ Complete - Dark mode fully integrated and tested
**Version**: 1.0
**Date**: June 28, 2025
