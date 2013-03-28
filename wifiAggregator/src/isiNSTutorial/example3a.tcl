#Info: Create 7 nodes and circularly connected links - no specific nam

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


#Call the finish procedure after 5 seconds simulation time
$ns at 5.0 "finish"

#Run the simulation
$ns run


