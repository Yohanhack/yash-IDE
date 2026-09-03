# YH-Termux IDE

Une IDE/TUI modulaire, légère et pensée pour Termux sur Android. Elle rassemble progressivement l’exploration de fichiers, l’édition, la recherche, Git, les paquets, le web et des sessions de terminal dans une interface clavier unique.

## État actuel — V0.4 Search

Le socle et le premier module sont utilisables. L’éditeur, la recherche et les autres modules arrivent dans les versions suivantes.

## Interface V1.1 — style lazygit

Une nouvelle interface Go est disponible dans `cmd/yh`. Elle propose une barre latérale, des panneaux avec bordures, thèmes de couleurs, navigation clavier (`↑/↓`, `j/k`, `Entrée`, `q`), ouverture par clic, et redimensionnement dynamique. À l’installation, `golang` est vérifié, `go mod tidy`, `go mod download` et `go build` sont exécutés, puis l’interface est construite dans `bin/yh-tui`; le lanceur `yh` l’utilise automatiquement.

### Design V1.1

Le tableau de bord comprend un en-tête d’état, un navigateur de modules et sessions, des cartes Workspace et Module actif, une activité récente, des raccourcis visibles, ainsi qu’un pied de page d’état. Les panneaux restent lisibles en portrait et se recalculent lors du changement de taille du terminal.

- commande d’entrée `yh` ;
- interface TUI en Bash et séquences ANSI ;
- tableau de bord avec les neuf futurs modules ;
- navigation au clavier avec `↑/↓` ou `j/k`, `Entrée` et `q` ;
- routeur : chaque module ouvre aujourd’hui un écran explicite « à venir » ;
- installation Termux via `install.sh` ;
- état central minimal : module sélectionné et workspace courant.
- explorateur de fichiers : Ranger est le moteur principal quand il est installé ; un fichier choisi ouvre directement l’éditeur intégré ;
- création de fichiers et dossiers depuis l’explorateur ;
- éditeur intégré : insertion de texte, déplacement, retours à la ligne, suppression, sauvegarde, recherche et undo.
- recherche récursive de contenu et ouverture directe du résultat dans l’éditeur.

## Démarrage dans Termux

```bash
git clone <URL_DU_DEPOT> yh-termux
cd yh-termux
chmod +x yh install.sh tests/smoke.sh
./tests/smoke.sh
./install.sh
yh
```

Le script d’installation vérifie Termux et `pkg`, met à jour les index puis vérifie/installe Ranger, tmux, Git, ripgrep, fd, fzf, lazygit, btop, ncdu et w3m un par un. Un échec de paquet ne bloque pas le reste ; le détail est écrit dans `install.log`. Il crée ensuite la commande `yh` dans `$PREFIX/bin`.

## Raccourcis V0.1

| Touche | Action |
| --- | --- |
| `↑` / `k` | Module précédent |
| `↓` / `j` | Module suivant |
| `Entrée` | Ouvrir l’écran du module |
| `q` | Quitter |

## Feuille de route

| Version | But | État |
| --- | --- | --- |
| V0.1 | Core, interface et navigation | Terminé |
| V0.2 | Explorateur de fichiers | Terminé |
| V0.3 | Éditeur intégré | Terminé |
| V0.4 | Recherche fichiers/contenu | Terminé |
| V0.5 | Terminal réel avec tmux | À faire |
| V0.6 | Git et lazygit | Terminé |
| V0.7 | Gestion des paquets Termux | Terminé |
| V0.8 | Web via w3m et favoris | Terminé |
| V0.9 | Stockage et système | Terminé |
| V1.0 | Finition IDE | En cours |

## Audit de l’architecture

L’arborescence prévue est maintenant présente : `core`, `ui`, `modules`, `integrations`, `services`, `utils`, `config`, `themes`, `data`, `tests` et `docs`. Les modules réellement fonctionnels sont **Explorer**, **Editor** et **Search**. Les dossiers Terminal, Git, Packages, Web, Storage et System ont été créés pour respecter l’architecture, mais ne sont pas annoncés comme implémentés.

## Journal d’évolution

### 2026-09-03 — V0.4.0

**Implémenté :** recherche récursive de contenu depuis le workspace, ignorant `.git`, liste navigable et ouverture du fichier choisi dans Editor.

**Limites connues :** la V0.4 utilise `grep` disponible par défaut, pas encore `rg`/`fd`/`fzf`. La recherche de noms de fichiers et les numéros de ligne arriveront avec la détection de dépendances.

### 2026-09-03 — V0.3.0

**Implémenté :** éditeur directement intégré au TUI. Un fichier sélectionné depuis Explorer s’ouvre dans son buffer ; `Ctrl+S` écrit le fichier, `Ctrl+Z` annule, `Ctrl+F` cherche, `Ctrl+Q` revient au tableau de bord.

**Limites connues :** le redo, le remplacement, la coloration syntaxique, les onglets et l’avertissement avant de quitter un buffer non sauvegardé restent à faire. L’éditeur est volontairement minimal à ce stade, mais ne délègue pas l’édition à Neovim ou Nano.

### 2026-09-03 — V0.2.0

**Implémenté :** l’intégration Ranger est maintenant le chemin principal : YH lance Ranger dans le dossier courant et récupère le fichier via `--choosefile`, puis l’ouvre directement dans Editor. L’explorateur interne reste disponible automatiquement si Ranger n’est pas installé.

**Pré-requis :** `pkg install ranger`. Ranger donne déjà accès à la navigation, la prévisualisation, la copie, le déplacement, le renommage et la suppression avec ses raccourcis natifs. L’éditeur intégré prend ensuite le relais pour modifier le fichier choisi.

### 2026-09-03 — V0.5.0

**Implémenté :** terminal persistant avec `tmux new-session -A -s yh-main` : les processus restent actifs à la sortie de l’écran terminal et reviennent à la session suivante. Le cœur traite `SIGWINCH` pour recalculer la largeur de l’interface lors d’un redimensionnement. Une courte transition ANSI et une palette cyan/vert/jaune accompagnent les changements de module.

**Limite :** tmux occupe temporairement tout le terminal, ce qui est la solution stable et native Termux pour un « terminal intégré » dans une TUI Bash. Quitter/détacher tmux (`Ctrl+B`, puis `D`) ramène au tableau de bord YH.

### 2026-09-03 — V0.6.0

**Implémenté :** module Git pour le workspace : statut, diff synthétique et détaillé, commit de tous les changements avec message, création/changement de branche, pull, push et ouverture de lazygit. Le module refuse proprement les dossiers qui ne sont pas des dépôts Git.

**Sécurité :** pull, push, commit et création de branche ne s’exécutent qu’après sélection explicite dans le menu. Le pull emploie `--ff-only` pour éviter un merge automatique inattendu.

### 2026-09-03 — V0.7.0

**Implémenté :** menu `pkg` pour mettre à jour les index, mettre à niveau, rechercher, installer, supprimer et lister les paquets. Les noms de paquets sont validés et la suppression exige une confirmation.

### 2026-09-03 — V0.8.0

**Implémenté :** navigateur textuel `w3m`, ouverture d’URL, ajout, affichage et ouverture de favoris. Les favoris sont stockés dans `~/.local/share/yh-termux/bookmarks` (ou `XDG_DATA_HOME`).

### 2026-09-03 — V0.9.0

**Implémenté :** Storage affiche l’espace disque, la taille du workspace, ses plus grands éléments et lance `ncdu`. System fournit un résumé, la liste des processus et lance `btop`. Chaque intégration indique précisément le paquet Termux manquant au lieu d’échouer silencieusement.

### Recherche — amélioration V1.0

**Implémenté :** deux modes : recherche de noms avec `fd` (ou `find` de secours) et recherche de contenu avec `rg` (ou `grep`). `fzf` est utilisé pour sélectionner rapidement lorsqu’il est installé ; sinon YH affiche sa liste intégrée. Les résultats de contenu affichent `fichier:ligne:texte` et ouvrent l’éditeur directement à la ligne trouvée.

### 2026-09-03 — V0.1.0

**Implémenté :** structure modulaire initiale (`core`, `ui`, `config`), boucle interactive, rendu du tableau de bord, sélection clavier, routeur et installation Termux.

**Décision :** les modules ne sont pas simulés. Ils restent clairement indiqués comme indisponibles jusqu’à leur implémentation réelle, à partir de V0.2.

**Bugs connus :** aucun identifié lors de la revue du code. La prise en charge des flèches a été corrigée pendant la V0.1 : le terminal envoie une séquence d’échappement et non une touche unique. Les terminaux non interactifs sont refusés volontairement.

**Validation :** `tests/smoke.sh` exécute `bash -n` sur tous les scripts. Le poste de développement Windows ne possède pas Bash, donc cette commande devra être lancée dans Termux avant d’utiliser l’application ; ce n’est pas encore une validation d’exécution sur Android.

### Correctif de démarrage

La commande installée `yh` est un lien symbolique vers ce dépôt. Le lanceur résout désormais ce lien avant de charger les scripts internes. Si l’erreur rencontrée contenait `.../bin/core/main.sh: No such file or directory`, mets à jour les fichiers puis relance `./install.sh`.

**Prochaine étape :** V0.2 — explorateur de fichiers, avec navigation, sélection et ouverture préparée pour le futur éditeur.
