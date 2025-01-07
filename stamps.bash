#!/bin/bash       



# Allow tactig usage with a relative wii directory
mkdir -p ./wii
echo "ab01b9d8e1622b08afbad84dbfc2a55d" > ./wii/sd-key
echo "216712e6aa1f689f95c5a22324dc6a98" > ./wii/sd-iv
echo "0e65378199be4517ab06ec22451a5793" > ./wii/md5-blanker
xxd -r -p ./wii/sd-key ./wii/sd-key
xxd -r -p ./wii/sd-iv ./wii/sd-iv
xxd -r -p ./wii/md5-blanker ./wii/md5-blanker


# Exits program if first argument is empty
if [ -z "$1" ]; then
    echo bash stamps.bash FILE
    echo FILE should be: Sports2.dat OR data.bin
    exit 1
# Exits program if file does not exist
elif [ ! -f "$1" ]; then
    echo "$1: No such file"
    exit 2
elif [ "${1: -3}" == "bin" ]; then
    tachtig "$1"
    hex=$(xxd -p -c 1000000 0001000053503245/Sports2.dat)
else
    hex=$(xxd -p -c 1000000 $1)
fi

# Convert date to human-readable format
convertDate() {
    if [ "$1" == "00000000" ]; then
        echo ""
    else
        x=`hexToBin $1`
        min=$((2#${x:25:6}))
        hour=$((2#${x:20:5}))
        day=$((2#${x:15:5}))
        month=$((2#${x:11:4}))
        year=$((2#${x:0:11}))
        monthNames=("January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")
        monthText=${monthNames[$((month - 1))]}
        echo "$monthText $day, $year $hour:$min"
    fi
}

# Start HTML output
cat <<EOF > output.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wii Sports Resort Stamps</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.6; }
        h1 { color: #333; }
        .player-section { margin-bottom: 30px; }
        .player-name { color: #d9534f; font-size: 1.5em; margin-bottom: 10px; }
        .player-total { color: #28a745; font-size: 1.2em; margin-bottom: 15px; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        table, th, td { border: 1px solid #ddd; }
        th, td { padding: 8px; text-align: center; }
        th { background-color: #f4f4f4; }
        td.stamp-none { background-color: #ccc; }
        td.stamp-collected { background-color: #d4edda; color: #155724; font-weight: bold; line-height: 1.2; }
        td.stamp-collected span { display: block; }
    </style>
</head>
<body>
    <h1>Wii Sports Resort Stamps</h1>
EOF

# Colors
DARKGRAY='\033[1;30m'
RED='\033[0;31m'    
LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'    
YELLOW='\033[1;33m'
BLUE='\033[0;34m'    
PURPLE='\033[0;35m'    
LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'    
WHITE='\033[1;37m'
SET='\033[0m'
echo -e "${RED}Wii ${BLUE}Sports ${PURPLE}Resort ${GREEN}Stamps${SET}"

doc() { x=$((16#$1)); printf "%d" $(($x*2));}
hexToDec() { x=$((16#$1)); printf "%d" $(($x));}
hexToBin() {
x=`toUpper $1`
BIN=$(echo "obase=2; ibase=16; $x" | bc )
echo $BIN
}
binToDec() {
BIN=$(echo "obase=10; ibase=2; $1" | bc )
echo $BIN
}
#twos compliment works on four digits only
twos() { x=$((16#$1)); [ "$x" -gt 32767 ] && ((x=x-65536)); printf "%+d " $x; }
secs() { printf "%d:%02d" $(($1/60)) $(($1%60));}
OneDate() {
x=`doc $1`
name_dec_pos=$((x+44))
hiOrRec=$((x+828))
new=$((x+832))
old=$((x+840))
min=${hex:x:8}
x=$((x-16))
y=$((x+28))
z=$((x+36))
a=$((x+44))
figureout=$((x+860))
if [ "${hex:x:8}" == "55705363" ] && [ "${hex:hiOrRec:4}" == "0000" ]; then
#readable="UpSc"
readable="Wii Record            "
elif [ "${hex:x:8}" == "55705363" ] && [ "${hex:hiOrRec:4}" == "0001" ]; then
#readable="UpSc"
readable="Personal Record       "
elif [ "${hex:x:8}" == "47556e69" ]; then
#readable="GUni"
readable="Stamp                 "
elif [ "${hex:x:8}" == "4d646c45" ] && [ "${hex:figureout:20}" == "00000000000300000001" ]; then
#readable="Mdle"
readable="All Pro Class         "
elif [ "${hex:x:8}" == "4d646c45" ] && [ "${hex:figureout:20}" == "00000000000400000000" ]; then
#readable="Mdle"
readable="Superstar Class       "
elif [ "${hex:x:8}" == "4d646c45" ] && [ "${hex:figureout:20}" == "00000000000400000001" ]; then
#readable="Mdle"
readable="All Superstar Class   "
elif [ "${hex:x:8}" == "4d646c45" ] ; then
#readable="Mdle"
readable="Pro Class             "
elif [ "${hex:x:8}" == "506c6179" ]; then
readable="Last Sport Played     "
else
readable=${hex:x:8}
fi
if [ "${hex:y:4}" == "0001" ] &&  [ "${hex:a:4}" == "0000" ]; then
sportin="Power Cruising - Beach"
elif [ "${hex:y:4}" == "0001" ]; then
sportin="Power Cruising"
elif [ "${hex:y:4}" == "0000" ]; then
sportin="Swordplay"
elif [ "${hex:y:4}" == "0002" ]; then
sportin="Archery"
elif [ "${hex:y:4}" == "0003" ]; then
sportin="Frisbee Dog"
elif [ "${hex:y:4}" == "0004" ] && [ "${hex:a:4}" == "0002" ]; then
	sportin="3 Point Contest"
elif [ "${hex:y:4}" == "0004" ]; then
sportin="Basketball"
elif [ "${hex:y:4}" == "0005" ] && [ "${hex:z:4}" == "0002" ]; then
	sportin="Standard Bowling"
elif [ "${hex:y:4}" == "0005" ] && [ "${hex:z:4}" == "0004" ]; then
	sportin="Spin Control Bowling"
elif [ "${hex:y:4}" == "0005" ]; then
	sportin="Bowling"
elif [ "${hex:y:4}" == "0006" ]; then
sportin="Canoeing"
elif [ "${hex:y:4}" == "0007" ]; then
sportin="Table Tennis"
elif [ "${hex:y:4}" == "0008" ] && [ "${hex:a:4}" == "0000" ]; then
sportin="Wakeboarding - Beginner"
elif [ "${hex:y:4}" == "0008" ]; then
sportin="Wakeboarding"
elif [ "${hex:y:4}" == "0009" ]; then
sportin="Island Flyover"
elif [ "${hex:y:4}" == "000a" ]; then
sportin="Golf"
elif [ "${hex:y:4}" == "000b" ]; then
sportin="Frisbee Golf"
elif [ "${hex:y:4}" == "000c" ]; then
sportin="Cycling"
elif [ "${hex:y:4}" == "000d" ] && [ "${hex:z:4}" == "0001" ]; then
	sportin="Skydiving"
elif [ "${hex:y:4}" == "000d" ]; then
	sportin="Air Sports"
elif [ "${hex:y:4}" == "000e" ]; then
sportin="000e Please look at your wii, identify the sport, and open an issue on GitHub."
elif [ "${hex:y:4}" == "000f" ]; then
sportin="000f Please look at your wii, identify the sport, and open an issue on GitHub."
fi

printf "%s %s %s " `hexToDate $min` " " "$readable" `hexToAscii ${hex:name_dec_pos:20}` $sportin
if [ "${hex:x:8}" == "55705363" ] && [ "${hex:y:4}" == "000a" ]; then
# Trying to show negative numbers for Golf
twos ${hex:((new+4)):4}
printf "<- "
twos ${hex:((old+4)):4}
elif [ "${hex:x:8}" == "55705363" ] && [ "${hex:y:4}" == "000b" ]; then
# Trying to show negative numbers for Frisbee/Golf
	twos ${hex:((new+4)):4} 
printf "<- "
twos ${hex:((old+4)):4}
elif [ "${hex:x:8}" == "55705363" ] && [ "${hex:y:4}" == "000c" ]; then
	#Cyling formatting the score
c1=${hex:((old+3)):5}
c1h=$((16${c1}))
c1s=${c1h:0:333}
c1ms=${c1h:3:2}
printf "%d %s.%02w" 0x${hex:((old+1)):2} `secs ${c1s}` ${c1ms}
	printf "<- "
c1=${hex:((new+3)):5}
c1h=$((16${c1}))
c1s=${c1h:0:333}
c1ms=${c1h:3:2}
printf "%d %s.%02w" 0x${hex:((new+1)):2} `secs ${c1s}` ${c1ms}
echo "untested: make an issue for cycling if scores do not make sense"
elif [ "${hex:x:8}" == "55705363" ]; then
printf "%d %s %d" `hexToDec ${hex:new:8}` "<-" `hexToDec ${hex:old:8}`
fi
echo
}
# sport() {
# printf "%s:\t" "$1" 
# x=$((offset+`doc $2`))
# 	for i in 1 2 3 4 5
# 	do
# min=${hex:x:8}
# if [ "$min" != "00000000" ]; then
# countStamps=$((countStamps+1))
# fi
# printf "%s %s  " `hexToDate $min`
# x=$((x+8))
# 	done
# echo
# }
hexToAscii() { 
	input=$1
	x=""
	for i in 2 6 10 14 18 22 26 30 34
	do
		if [ "${input:$i:2}" == "20" ]; then
	x+=" "
		elif [ "${input:$i:2}" == "00" ]; then
			x+=" "
		else
	x+=$(echo ${input:$i:2} | xxd -r -p)
		fi
done
	echo $x
}
hexToDate() { #printf "%s:\n" $1; 
if [ "$1" == "00000000" ]; then
printf "==============="
else
x=`hexToBin $1`
min=${x:25:6}
hour=${x:20:5}
day=${x:15:5}
month=${x:11:4}
year=${x:0:11}
#echo `binToDec $min`
#echo `binToDec $hour`
#echo `binToDec $day`
#echo `binToDec $month`
#echo `binToDec $year`
m=$((`binToDec $month`+1))
printf "%02d/%02d/%04d %02d:%02d  " $m `binToDec $day` `binToDec $year` `binToDec $hour` `binToDec $min`
fi
}
toUpper() {
echo ${1^^}
}

offset=0
for i in {1..12}
do
    z=$((offset+`doc 82c0`))
    name=`hexToAscii ${hex:z:30}`
    countStamps=0  # Initialize/reset for the current player

    if [[ ! "$name" =~ ^(miss\ ho|capt\.ja|unc)$ ]]; then
        continue
    fi  

    # Add rows for each sport
    sport() {
        echo "            <tr><td>$1</td>" >> output.html
        x=$((offset+`doc $2`))
        for i in 1 2 3 4 5; do
            min=${hex:x:8}
            if [ "$min" != "00000000" ]; then
                stamp=`convertDate $min`
                echo "<td class=\"stamp-collected\"><span>Collected</span><span>$stamp</span></td>" >> output.html
                countStamps=$((countStamps + 1))  # Increment countStamps
                echo $countStamps  # Debugging output
            else
                echo "<td class=\"stamp-none\"></td>" >> output.html
            fi
            x=$((x+8))
        done
        echo "</tr>" >> output.html
    }

	echo "        <div class=\"player-name\">$name</div>" >> output.html
	# Process all sports and update countStamps
    echo "        <table>" >> output.html
    echo "            <thead>" >> output.html
    echo "                <tr><th>Sport</th><th>Stamp1</th><th>Stamp2</th><th>Stamp3</th><th>Stamp4</th><th>Stamp5</th></tr>" >> output.html
    echo "            </thead>" >> output.html
    echo "            <tbody>" >> output.html

    # Call sports
    sport "Showdown" "8cec"
    sport "Swordplay Duel" "8d00"
    sport "Speed Slice" "8d14"
    sport "Power Cruising" "8d28"
    sport "Archery" "8d50"
    sport "Frisbee Dog" "8d64"
    sport "3 Point Contest" "8d78"
    sport "Pickup Basketball" "8d8c"
    sport "Standard Bowling" "8d9c"
    sport "100 Pin Bowling" "8db4"
    sport "Spin Control" "8dc8"
    sport "Frisbee Golf" "8df0"
    sport "Return Table Tennis" "8e04"
    sport "Table Tennis Match" "8e18"
    sport "Wakeboarding" "8e2c"
    sport "Island Flyover" "8e40"
    sport "Golf" "8e68"
    sport "Canoeing" "8e7c"
    sport "Cycling" "8ea4"
    sport "Skydiving" "8eb8"

    echo "            </tbody>" >> output.html
    echo "        </table>" >> output.html

    # Player Section (AFTER sports have been processed)
    echo "    <div class=\"player-section\">" >> output.html
    
    echo "        <div class=\"player-total\">Total Stamps: $countStamps / 100</div>" >> output.html
    echo "    </div>" >> output.html

    # Debugging output to verify countStamps
    echo "OUTTHECOUNT: $countStamps" >&2

    # Update offset for the next player
    interval=`doc df4`
    offset=$((offset+interval))
done

# End HTML output
cat <<EOF >> output.html
</body>
</html>
EOF

echo "HTML output generated in output.html"