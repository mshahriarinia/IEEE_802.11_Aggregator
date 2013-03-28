#Info: Create one sender one receiver, start/stop traffic
# traffic takes the shortest path

#Create a simulator object
set ns [new Simulator]

#Open the nam trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
	#Close the trace file
        close $nf
	#Execute nam on the trace file
        exec nam out.nam &
        exit 0
}


# Insert your own code for topology creation
# and agent definitions, etc. here

# Create 7 nodes
for {set i 0} {$i < 7} {incr i} {
  set n($i) [$ns node]
}

# Create links
for {set i 0} {$i < 7} {incr i} {
  $ns duplex-link $n($i) $n([expr ($i+1)%7]) 1Mb 10ms DropTail
}

#---------------------------------------
#Create a UDP agent and attach it to node n(0)
set udp0 [new Agent/UDP]
$ns attach-agent $n(0) $udp0

# Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

# Create the receiver and attach it to node n(0)
set null0 [new Agent/Null]
$ns attach-agent $n(3) $null0

#Connect the transmitter and the receiver
$ns connect $udp0 $null0

# Start/stop trafic
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"
#---------------------------------------




#Call the finish procedure after 5 seconds simulation time
$ns at 5.0 "finish"

#Run the simulation
$ns run


