package main

import (
	"fmt"
	"os"
	"os/exec"

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
	border = lipgloss.NewStyle().Border(lipgloss.RoundedBorder()).BorderForeground(lipgloss.Color("63"))
	title = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("86"))
	active = lipgloss.NewStyle().Foreground(lipgloss.Color("86")).Bold(true).Background(lipgloss.Color("237"))
	muted = lipgloss.NewStyle().Foreground(lipgloss.Color("245"))
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
	return func() tea.Msg { return doneMsg{cmd.Run()} }
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
		if msg.X < 28 && msg.Y >= 3 && msg.Y < 3+len(m.modules) { m.selected = msg.Y - 3; m.status = m.modules[m.selected].name + " selected" }
	case doneMsg:
		if msg.err != nil { m.status = msg.err.Error() } else { m.status = "Returned to YH-Termux" }
	}
	return m, nil
}

func (m model) View() string {
	left := title.Render("YH-TERMUX IDE") + "\n" + muted.Render(m.workspace) + "\n\n"
	for i, item := range m.modules {
		line := fmt.Sprintf(" %s  %s", item.icon, item.name)
		if i == m.selected { left += active.Width(24).Render(line) + "\n" } else { left += line + "\n" }
	}
	panel := title.Render(m.modules[m.selected].name) + "\n\n" + muted.Render("Select a module from the sidebar.\nMouse and keyboard are enabled.\n\nExternal tools open in the same terminal.")
	leftBox := border.Width(26).Height(max(14, m.height-5)).Render(left)
	rightBox := border.Width(max(35, m.width-32)).Height(max(14, m.height-5)).Render(panel)
	return lipgloss.JoinHorizontal(lipgloss.Top, leftBox, rightBox) + "\n" + muted.Render(m.status)
}

func max(a, b int) int { if a > b { return a }; return b }

func main() {
	p := tea.NewProgram(initialModel(), tea.WithAltScreen(), tea.WithMouseCellMotion())
	if _, err := p.Run(); err != nil { fmt.Fprintln(os.Stderr, err); os.Exit(1) }
}
