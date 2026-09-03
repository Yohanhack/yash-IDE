package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type module struct { name, icon, command string }
type doneMsg struct{ err error }

type model struct {
	modules []module
	selected int
	width, height int
	workspace string
	status string
}

var (
	border = lipgloss.NewStyle().Border(lipgloss.RoundedBorder()).BorderForeground(lipgloss.Color("63")).Padding(0, 1)
	title = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("86"))
	active = lipgloss.NewStyle().Foreground(lipgloss.Color("86")).Bold(true).Background(lipgloss.Color("237")).Padding(0, 1)
	muted = lipgloss.NewStyle().Foreground(lipgloss.Color("245"))
	label = lipgloss.NewStyle().Foreground(lipgloss.Color("63")).Bold(true)
	good = lipgloss.NewStyle().Foreground(lipgloss.Color("42"))
	card = lipgloss.NewStyle().Border(lipgloss.NormalBorder()).BorderForeground(lipgloss.Color("240")).Padding(1, 2)
)

func initialModel() model {
	wd, _ := os.Getwd()
	return model{workspace: wd, status: "↑↓/j k navigate • Enter open • mouse click • q quit", modules: []module{
		{"Explorer", "󰉋", "ranger"}, {"Editor", "󰈙", ""}, {"Search", "󰍉", ""},
		{"Web", "󰖟", "w3m"}, {"Packages", "󰏖", ""}, {"Git", "󰊢", "lazygit"},
		{"Storage", "󰋊", "ncdu"}, {"Terminal", "󰆍", "tmux"}, {"System", "󰍛", "btop"}, {"Settings", "󰒓", ""},
	}}
}

func (m model) Init() tea.Cmd { return nil }

func (m model) runSelected() tea.Cmd {
	item := m.modules[m.selected]
	if item.command == "" { return func() tea.Msg { return doneMsg{fmt.Errorf("%s is being migrated to the new interface", item.name)} } }
	cmd := exec.Command(item.command)
	cmd.Dir = m.workspace
	if item.command == "tmux" { cmd = exec.Command("tmux", "new-session", "-A", "-s", "yh-main") }
	if item.command == "w3m" { return func() tea.Msg { return doneMsg{fmt.Errorf("enter a URL in the Bash Web module during migration")} } }
	// ExecProcess rend temporairement le terminal au programme TUI enfant.
	// Ranger, lazygit, ncdu, btop et tmux peuvent ainsi recevoir clavier, souris
	// et redimensionnements avant le retour automatique à YH.
	return tea.ExecProcess(cmd, func(err error) tea.Msg { return doneMsg{err} })
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
	case tea.KeyMsg:
		switch msg.String() {
		case "q", "ctrl+c": return m, tea.Quit
		case "up", "k": m.selected = (m.selected + len(m.modules)-1) % len(m.modules)
		case "down", "j": m.selected = (m.selected + 1) % len(m.modules)
		case "enter": m.status = "Opening " + m.modules[m.selected].name + "…"; return m, m.runSelected()
		}
	case tea.MouseMsg:
		if msg.X < 28 && msg.Y >= 3 && msg.Y < 3+len(m.modules) {
			m.selected = msg.Y - 3
			m.status = "Opening " + m.modules[m.selected].name + "…"
			return m, m.runSelected()
		}
	case doneMsg:
		if msg.err != nil { m.status = msg.err.Error() } else { m.status = "Returned to YH-Termux" }
	}
	return m, nil
}

func (m model) View() string {
	if m.width == 0 { return "Starting YH-Termux…" }
	if m.width < 80 {
		compact := title.Render("YH-TERMUX IDE") + "  " + good.Render("● READY") + "\n" + muted.Render(m.workspace) + "\n\n"
		for i, item := range m.modules {
			line := item.icon + "  " + item.name
			if i == m.selected { compact += active.Render(line) + "\n" } else { compact += line + "\n" }
		}
		compact += "\n" + muted.Render(m.status)
		return border.Width(max(36, m.width-2)).Render(compact)
	}
	header := title.Render(" YH-TERMUX ") + muted.Render("  IDE workspace for Termux") + "                                  " + good.Render("● READY")
	left := label.Render("NAVIGATOR") + "\n" + muted.Render("Workspace modules") + "\n\n"
	for i, item := range m.modules {
		line := fmt.Sprintf(" %s  %s", item.icon, item.name)
		if i == m.selected { left += active.Width(24).Render(line) + "\n" } else { left += line + "\n" }
	}
	left += "\n" + label.Render("SESSIONS") + "\n" + good.Render("● Main") + "\n" + muted.Render("○ Terminal\n○ Server")

	workspace := card.Width(max(22, (m.width-34)/2)).Render(
		label.Render("WORKSPACE") + "\n" + title.Render(filepathBase(m.workspace)) + "\n" + muted.Render(m.workspace),
	)
	selected := m.modules[m.selected]
	action := card.Width(max(22, (m.width-34)/2)).Render(
		label.Render("ACTIVE MODULE") + "\n" + title.Render(selected.icon+"  "+selected.name) + "\n" + muted.Render("Click the sidebar item or press Enter"),
	)
	activity := card.Width(max(48, m.width-34)).Render(
		label.Render("ACTIVITY") + "\n" + good.Render("● ")+"Interface ready"+"\n"+
		muted.Render("Open Explorer to browse with Ranger, then edit a selected file."),
	)
	quick := card.Width(max(48, m.width-34)).Render(
		label.Render("QUICK ACTIONS") + "\n" +
		"[ Enter ] Open module     [ Ctrl+T ] Terminal     [ Ctrl+P ] Search\n" +
		muted.Render("Mouse: click a module in the navigator to open it."),
	)
	right := title.Render("DASHBOARD") + "\n" + muted.Render("Your Termux development environment") + "\n\n" +
		lipgloss.JoinHorizontal(lipgloss.Top, workspace, action) + "\n" + activity + "\n" + quick
	leftBox := border.Width(27).Height(max(18, m.height-5)).Render(left)
	rightBox := border.Width(max(50, m.width-33)).Height(max(18, m.height-5)).Render(right)
	footer := muted.Render("  ") + good.Render("● ") + muted.Render(m.status)
	return border.Width(max(78, m.width-2)).Render(header) + "\n" + lipgloss.JoinHorizontal(lipgloss.Top, leftBox, rightBox) + "\n" + footer
}

func max(a, b int) int { if a > b { return a }; return b }

func filepathBase(path string) string {
	base := filepath.Base(path)
	if base == "." || base == "/" { return path }
	return base
}

func main() {
	p := tea.NewProgram(initialModel(), tea.WithAltScreen(), tea.WithMouseCellMotion())
	if _, err := p.Run(); err != nil { fmt.Fprintln(os.Stderr, err); os.Exit(1) }
}
