// General functionality for the entire site

// Function to get a cookie by name (for CSRF token)
function getCookie(name) {
    let cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        const cookies = document.cookie.split(';');
        for (let i = 0; i < cookies.length; i++) {
            const cookie = cookies[i].trim();
            if (cookie.substring(0, name.length + 1) === (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}

// Debounce function to limit how often a function can be called
function debounce(func, wait) {
    let timeout;
    return function() {
        const context = this;
        const args = arguments;
        clearTimeout(timeout);
        timeout = setTimeout(() => {
            func.apply(context, args);
        }, wait);
    };
}

// Function to format date
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString();
}

// Function to add animation classes
function animateElement(element, animationClass) {
    element.classList.add(animationClass);
    element.addEventListener('animationend', () => {
        element.classList.remove(animationClass);
    });
}

// Add fade in animation to elements with .fade-in class
document.addEventListener('DOMContentLoaded', () => {
    const fadeElements = document.querySelectorAll('.fade-in');
    fadeElements.forEach(el => {
        setTimeout(() => {
            el.classList.add('visible');
        }, 100);
    });
});

// Track game statistics in localStorage
function saveGameStats(gameType, isWon, attempts) {
    let stats = JSON.parse(localStorage.getItem('lolGameStats') || '{}');

    if (!stats[gameType]) {
        stats[gameType] = {
            played: 0,
            won: 0,
            totalAttempts: 0,
            lastPlayed: null
        };
    }

    stats[gameType].played += 1;
    if (isWon) {
        stats[gameType].won += 1;
    }
    stats[gameType].totalAttempts += attempts;
    stats[gameType].lastPlayed = new Date().toISOString();

    localStorage.setItem('lolGameStats', JSON.stringify(stats));
}

// Get game statistics from localStorage
function getGameStats(gameType) {
    const stats = JSON.parse(localStorage.getItem('lolGameStats') || '{}');
    return stats[gameType] || null;
}