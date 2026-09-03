# Architecture V0.1

`yh` charge `core/main.sh`, qui initialise l’état puis affiche l’interface. `core/router.sh` transforme les touches en actions. `ui/renderer.sh` ne contient que le rendu, et `config/config.sh` les constantes applicatives.

Les futurs modules seront ajoutés sous `modules/` et passeront par le routeur ; ils ne devront pas appeler directement l’interface d’un autre module.
