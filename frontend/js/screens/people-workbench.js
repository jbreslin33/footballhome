// PeopleWorkbenchScreen — lightweight, people-focused workbench that
// routes the new Club Admin People tiles to a concrete screen.
// It is intentionally simple and data-driven so it can grow into a
// full directory/merge dashboard without another route churn.
class PeopleWorkbenchScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="people-workbench-title">People Workbench</h1>
        <p class="subtitle" id="people-workbench-subtitle">People workflow</p>
      </div>

      <div style="padding: var(--space-4);">
        <div style="margin-bottom: var(--space-3);">
          <h2 id="people-workbench-view" style="margin-bottom: var(--space-1);">View</h2>
          <p id="people-workbench-description" style="opacity: 0.7; margin: 0;">People-focused operations and triage.</p>
        </div>

        <div style="display: grid; gap: var(--space-3);">
          <div style="padding: var(--space-4); border: 1px solid var(--color-border); border-radius: var(--radius-lg); background: var(--bg-secondary);">
            <p style="margin: 0 0 var(--space-2); font-weight: 700;">Current focus</p>
            <p id="people-workbench-status" style="margin: 0; opacity: 0.8;">This screen is now wired up as the People-facing landing spot for the new Club Admin tiles.</p>
          </div>

          <div style="padding: var(--space-4); border: 1px solid var(--color-border); border-radius: var(--radius-lg);">
            <p style="margin: 0 0 var(--space-2); font-weight: 700;">Next steps</p>
            <ul style="margin: 0; padding-left: 1.2rem; opacity: 0.8; line-height: 1.6;">
              <li>Connect this workbench to the real person directory API.</li>
              <li>Surface accounts, players, coaches/admins, duplicates, and data issues as focused sub-views.</li>
              <li>Keep scraped league/opponent-only people out of the default Lighthouse workflow.</li>
            </ul>
          </div>
        </div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    const title = params?.title || 'People Workbench';
    const subtitle = params?.subtitle || 'People workflow';
    const description = params?.description || 'People-focused operations and triage.';
    const view = params?.view || 'people';

    this.find('#people-workbench-title').textContent = title;
    this.find('#people-workbench-subtitle').textContent = subtitle;
    this.find('#people-workbench-view').textContent = `View · ${view}`;
    this.find('#people-workbench-description').textContent = description;
    this.find('#people-workbench-status').textContent = `This workbench is active for ${title.toLowerCase()} with the current Club Admin flow.`;

    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
      }
    });
  }
}
