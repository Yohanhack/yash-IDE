# YH-Termux IDE

Une IDE/TUI modulaire, légère et pensée pour Termux sur Android. Elle rassemble progressivement l’exploration de fichiers, l’édition, la recherche, Git, les paquets, le web et des sessions de terminal dans une interface clavier unique.

## État actuel — V0.4 Search

Le socle et le premier module sont utilisables. L’éditeur, la recherche et les autres modules arrivent dans les versions suivantes.

- commande d’entrée `yh` ;
- interface TUI en Bash et séquences ANSI ;
- tableau de bord avec les neuf futurs modules ;
- navigation au clavier avec `↑/↓` ou `j/k`, `Entrée` et `q` ;
- routeur : chaque module ouvre aujourd’hui un écran explicite « à venir » ;
- installation Termux via `install.sh` ;
- état central minimal : module sélectionné et workspace courant.
- explorateur de fichiers : navigation, remontée au dossier parent, ouverture de dossiers et sélection de fichiers ;
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

Le script d’installation crée le lien de la commande `yh` dans `$PREFIX/bin`, ainsi que les répertoires de configuration et de données de l’application. Il doit donc être exécuté depuis Termux.

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
| V0.6–V1.0 | Git, paquets, web, système et finition | À faire |

## Journal d’évolution

### 2026-09-03 — V0.4.0

**Implémenté :** recherche récursive de contenu depuis le workspace, ignorant `.git`, liste navigable et ouverture du fichier choisi dans Editor.

**Limites connues :** la V0.4 utilise `grep` disponible par défaut, pas encore `rg`/`fd`/`fzf`. La recherche de noms de fichiers et les numéros de ligne arriveront avec la détection de dépendances.

### 2026-09-03 — V0.3.0

**Implémenté :** éditeur directement intégré au TUI. Un fichier sélectionné depuis Explorer s’ouvre dans son buffer ; `Ctrl+S` écrit le fichier, `Ctrl+Z` annule, `Ctrl+F` cherche, `Ctrl+Q` revient au tableau de bord.

**Limites connues :** le redo, le remplacement, la coloration syntaxique, les onglets et l’avertissement avant de quitter un buffer non sauvegardé restent à faire. L’éditeur est volontairement minimal à ce stade, mais ne délègue pas l’édition à Neovim ou Nano.

### 2026-09-03 — V0.2.0

**Implémenté :** explorateur de fichiers intégré avec affichage des dossiers avant les fichiers, navigation clavier, accès au parent, création de fichier/dossier et transfert du fichier choisi vers le futur éditeur.

**Limites connues :** renommer, supprimer, copier, déplacer, favoris et aperçu sont reportés ; ils seront ajoutés avec les services de fichiers au cours des prochaines versions. Les noms contenant `/` sont volontairement refusés dans la boîte de création pour éviter une création hors du dossier affiché.

### 2026-09-03 — V0.1.0

**Implémenté :** structure modulaire initiale (`core`, `ui`, `config`), boucle interactive, rendu du tableau de bord, sélection clavier, routeur et installation Termux.

**Décision :** les modules ne sont pas simulés. Ils restent clairement indiqués comme indisponibles jusqu’à leur implémentation réelle, à partir de V0.2.

**Bugs connus :** aucun identifié lors de la revue du code. La prise en charge des flèches a été corrigée pendant la V0.1 : le terminal envoie une séquence d’échappement et non une touche unique. Les terminaux non interactifs sont refusés volontairement.

**Validation :** `tests/smoke.sh` exécute `bash -n` sur tous les scripts. Le poste de développement Windows ne possède pas Bash, donc cette commande devra être lancée dans Termux avant d’utiliser l’application ; ce n’est pas encore une validation d’exécution sur Android.

**Prochaine étape :** V0.2 — explorateur de fichiers, avec navigation, sélection et ouverture préparée pour le futur éditeur.
