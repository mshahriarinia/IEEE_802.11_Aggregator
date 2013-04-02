# ===================================================
# Author: Morteza Shahriari Nia 01/21/2013
# This is a network of 100 nodes which operate at 802.11 
# and have one node as base station to which everybody tranmists.
# We want to analyze that as the number of the nodes 
# increases and as the packet length become smaller
# utilization decreases dramatically and nodes spend most 
# of their time contending to gain resources.
# ==================================================

# CBR: Constant bit rate generator
set cbr_size 500     
set cbr_interval 0.002
set num_row 3
set time_duration 100
#set land_size 1000 #land side length
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(rp) DSDV ;# routing protocol

# Initialize ns
set ns_ [new Simulator]
set tracefd [open simple.tr w]
$ns_ trace-all $tracefd

################################## NAM

#Define different colors for data flows (for NAM)
$ns_ color 1 Blue

#Open the NAM trace file
set nf [open outAgg.nam w]
$ns_ namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns_ flush-trace
        #Close the NAM trace file
        close $nf
        #Execute NAM on the trace file
        exec nam out.nam &
        exit 0
}
################################## NAM

# set up topography object
set topo       [new Topography]
$topo load_flatgrid 10 10
create-god [expr $num_row * $num_row ]
$ns_ node-config -adhocRouting $val(rp)\
     -llType $val(ll) \
     -macType $val(mac)  -ifqType $val(ifq) \
     -ifqLen $val(ifqlen) -antType $val(ant) \
     -propType $val(prop) -phyType $val(netif) \
     -channel  [new $val(chan)] -topoInstance $topo \
     -agentTrace OFF -routerTrace OFF\
     -macTrace ON \
     -movementTrace OFF
# CREATE 4*4 NODES
for {set i 0} {$i < [expr $num_row*$num_row]} {incr i} {
    set node_($i) [$ns_ node]
}
#ASSIGN COORDINATES
set k 0;
while {$k < $num_row } {
    for {set i 0} {$i < $num_row } {incr i} {
set m [expr $i+$k*$num_row];
$node_($m) set X_ [expr $i*10];
$node_($m) set Y_ [expr $k*10+10.0];
$node_($m) set Z_ 0.0
    }
    incr k;
}; 

#CREATE 4 UDP SENDERS AND 1 NULL RECEIVERS (FOR UDP)
for {set i 0} {$i < [expr $num_row*$num_row] } {incr i} {
    set udp_($i) [new Agent/UDP]    
} 
#ONLY ONE RECEIVER (BASE STATION)
set null_(0) [new Agent/Null]
#ATTACH PROTOCOLS TO NODES (SENDERS)
for {set i 0} {$i < [expr $num_row*$num_row]} {incr i} {
$ns_ attach-agent $node_($i) $udp_($i)
}

set baseIndex  [expr $num_row * $num_row / 2 - 1]
#ONLY ONE BASE STATION
#$ns_ attach-agent $node_($baseIndex ) $null_(0)
$ns_ attach-agent $node_(3 ) $null_(0)       #set base station index
# CREATE THE ACTUAL FLOW
for {set i 0} {$i < [expr $num_row*$num_row]} {incr i} {
     $ns_ connect $udp_($i) $null_(0)
}
#CREATE 4 CBRs  
for {set i 0} {$i < [expr $num_row*$num_row]} {incr i} {
    set cbr_($i) [new Application/Traffic/CBR]
    $cbr_($i) set packetSize_ $cbr_size #PACKET SIZE
    $cbr_($i) set interval_ 0.5     #BURST INTERVAL
    $cbr_($i) set rate_ 1mb
    $cbr_($i) attach-agent $udp_($i) 
    $ns_ at [expr 11.0234 + 0.005] "$cbr_($i) start"
} 
#START PACKET GENERATION
#$ns_ at 11.0234 "$cbr_(0) start"
#$ns_ at 10.4578 "$cbr_(1) start" 
#$ns_ at 12.7184 "$cbr_(2) start"
#$ns_ at 12.2456 "$cbr_(3) start" 
#TERMINATE THE SIMULATOR
# Tell nodes when the simulation ends
for {set i 0} {$i < [expr $num_row*$num_row] } {incr i} {
    $ns_ at [expr $time_duration +10.0] "$node_($i) reset";
}
$ns at 5.0 "finish"
#$ns_ at [expr $time_duration +10.0] "finish"
$ns_ at [expr $time_duration +10.01] "puts \"NS Exiting...\"; $ns_ halt"
proc finish {} {
global ns_ tracefd
$ns_ flush-trace
close $tracefd
}
puts "Starting Simulation..."
$ns_ run 

