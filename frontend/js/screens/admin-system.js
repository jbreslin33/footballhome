// AdminSystemScreen - Placeholder for system-level administration
class AdminSystemScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-admin-system';
    
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>System Administration</h1>
        <p class="subtitle">System-level admin features</p>
      </div>
      
      <div style="padding: var(--space-4); max-width: 800px; margin: 0 auto;">
        <div style="background: var(--bg-secondary); border-radius: var(--radius-lg); padding: var(--space-4); text-align: center;">
          <span style="font-size: 4rem; display: block; margin-bottom: var(--space-3);">👨‍💼</span>
          <h2 style="margin-bottom: var(--space-2);">System Administration</h2>
          <p style="opacity: 0.8; margin-bottom: var(--space-4);">
            Admin level: <strong>SYSTEM</strong>
          </p>
          <p style="opacity: 0.6;">
            System-level management features coming soon...
          </p>
        </div>
      </div>
    `;
    
    this.element = div;
    return div;
  }
  
  onEnter(params) {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
      }
    });
  }
}
