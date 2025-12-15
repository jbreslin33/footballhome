const { JSDOM } = require('jsdom');

/**
 * Base HTML Parser
 * Wraps JSDOM and provides common parsing utilities
 */
class HtmlParser {
  constructor() {
    this.dom = null;
    this.document = null;
  }

  /**
   * Parse HTML string into DOM
   */
  parse(html) {
    this.dom = new JSDOM(html);
    this.document = this.dom.window.document;
    return this;
  }

  /**
   * Query selectors (chainable)
   */
  querySelector(selector) {
    return this.document ? this.document.querySelector(selector) : null;
  }

  querySelectorAll(selector) {
    return this.document ? Array.from(this.document.querySelectorAll(selector)) : [];
  }

  /**
   * Get text content safely
   */
  getText(selector) {
    const element = this.querySelector(selector);
    return element ? element.textContent.trim() : null;
  }

  /**
   * Get attribute safely
   */
  getAttribute(selector, attribute) {
    const element = this.querySelector(selector);
    return element ? element.getAttribute(attribute) : null;
  }

  /**
   * Extract all links matching a pattern
   */
  getLinks(selector, hrefPattern = null) {
    const links = this.querySelectorAll(selector);
    return links
      .map(link => ({
        text: link.textContent.trim(),
        href: link.getAttribute('href')
      }))
      .filter(link => !hrefPattern || (link.href && link.href.includes(hrefPattern)));
  }

  /**
   * Parse table into array of objects
   */
  parseTable(tableSelector, options = {}) {
    const table = this.querySelector(tableSelector);
    if (!table) return [];

    const rows = Array.from(table.querySelectorAll('tr'));
    if (rows.length === 0) return [];

    // Get headers
    const headerRow = options.headerRow !== undefined ? rows[options.headerRow] : rows[0];
    const headers = Array.from(headerRow.querySelectorAll('th, td'))
      .map(cell => cell.textContent.trim());

    // Parse data rows
    const dataStartIndex = options.headerRow !== undefined ? options.headerRow + 1 : 1;
    const data = [];

    for (let i = dataStartIndex; i < rows.length; i++) {
      const cells = Array.from(rows[i].querySelectorAll('td'));
      if (cells.length === 0) continue;

      const row = {};
      cells.forEach((cell, index) => {
        const header = headers[index] || `column_${index}`;
        row[header] = cell.textContent.trim();
      });

      data.push(row);
    }

    return data;
  }

  /**
   * Clean up text (remove extra whitespace, newlines, etc.)
   */
  cleanText(text) {
    if (!text) return '';
    return text
      .replace(/\s+/g, ' ')
      .replace(/\n+/g, ' ')
      .trim();
  }

  /**
   * Extract number from text
   */
  extractNumber(text) {
    if (!text) return null;
    const match = text.match(/[\d.]+/);
    return match ? parseFloat(match[0]) : null;
  }

  /**
   * Check if element exists
   */
  exists(selector) {
    return this.querySelector(selector) !== null;
  }

  /**
   * Clean up
   */
  destroy() {
    if (this.dom && this.dom.window) {
      this.dom.window.close();
    }
    this.dom = null;
    this.document = null;
  }
}

module.exports = HtmlParser;
