class ToolManager {
  constructor(board) { this.board = board; this.tools = {}; }
  register(name, tool) { this.tools[name] = tool; }
}
window.ToolManager = ToolManager;
