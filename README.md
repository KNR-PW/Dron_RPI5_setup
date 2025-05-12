# Setup
1. Instalacja z rpi imagerem ubuntu 24.04.02 desktop
2. Wpięcie karty do rpi, podpięcie zasilania, myszki, klawiatury ekranu
3. Przejscie przez setup ustawienie hostname oraz wifi i hasło
Update systemu
4. sudo apt update && sudo apt full-upgrade
instalacja ssh
5. sudo apt install openssh-server
właczenie przy autostarcie sshhos
6. sudo systemctl enable ssh
Możemy się połączyc
ssh <hostname>@<ip>
