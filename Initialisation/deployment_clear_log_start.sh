echo ""
echo "################################################################"
echo "Clearing all Log- and Output-Files"
../cleanlogs.sh
echo "removed logs from Repository"

sleep 5.0

./startServices.sh
