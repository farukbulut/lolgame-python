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

    // Bildirim kapatma butonunu ayarla
    const notificationClose = document.getElementById('notification-close');
    if (notificationClose) {
        notificationClose.addEventListener('click', () => {
            document.getElementById('notification').classList.add('hidden');
        });
    }
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

// Konfeti efekti
function startConfetti() {
    const canvas = document.getElementById('confetti-canvas');
    const ctx = canvas.getContext('2d');
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    const particles = [];
    const particleCount = 150;
    const gravity = 0.3;
    const colors = ['#d4af37', '#FFD700', '#FFA500', '#FF4500', '#9370DB', '#00BFFF'];
    const spread = 60;

    // Parça oluştur
    for (let i = 0; i < particleCount; i++) {
        particles.push({
            x: canvas.width / 2,
            y: canvas.height / 2,
            size: Math.random() * 10 + 5,
            color: colors[Math.floor(Math.random() * colors.length)],
            vx: Math.random() * spread - spread/2,
            vy: Math.random() * -15 - 5,
            rotation: Math.random() * 360,
            rotationSpeed: Math.random() * 10 - 5
        });
    }

    // Animasyon
    function animate() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        let particlesLeft = false;

        for (let i = 0; i < particles.length; i++) {
            const p = particles[i];
            ctx.fillStyle = p.color;

            // Parçaları çiz
            ctx.save();
            ctx.translate(p.x, p.y);
            ctx.rotate(p.rotation * Math.PI / 180);

            // Konfeti parçası - dikdörtgen
            ctx.fillRect(-p.size/2, -p.size/4, p.size, p.size/2);

            ctx.restore();

            // Fizik
            p.x += p.vx;
            p.y += p.vy;
            p.vy += gravity;
            p.rotation += p.rotationSpeed;

            // Ekrandan çıktı mı kontrol et
            if (p.y < canvas.height + 100) {
                particlesLeft = true;
            }
        }

        // Hala parçalar varsa animasyona devam et
        if (particlesLeft) {
            requestAnimationFrame(animate);
        } else {
            canvas.style.display = 'none';
        }
    }

    // Konfeti başlat
    canvas.style.display = 'block';
    animate();
}

// Bildirim gösterme fonksiyonu
function showNotification(message) {
    const notification = document.getElementById('notification');
    const messageElement = document.getElementById('notification-message');

    messageElement.textContent = message;
    notification.classList.remove('hidden');

    // Otomatik kapanma süresi
    setTimeout(() => {
        notification.classList.add('hidden');
    }, 5000);

    // Kapatma butonu
    document.getElementById('notification-close').addEventListener('click', () => {
        notification.classList.add('hidden');
    });
}
