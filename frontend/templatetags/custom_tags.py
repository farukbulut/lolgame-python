# Create a new file: frontend/templatetags/custom_tags.py

from django import template

register = template.Library()

@register.filter(name='sub')
def subtract(value, arg):
    """Subtracts the arg from the value."""
    try:
        return int(value) - int(arg)
    except (ValueError, TypeError):
        try:
            return value - arg
        except Exception:
            return value