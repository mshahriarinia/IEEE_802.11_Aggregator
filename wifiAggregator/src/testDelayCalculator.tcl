set ns [new Simulator]
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set f [open out.tr w]
$ns trace-all $f
$ns duplex-link $n0 $n2 5Mb 2ms DropTail
$ns duplex-link $n1 $n2 5Mb 2ms DropTail
$ns duplex-link $n2 $n3 1.5Mb 10ms DropTail
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $tcp $sink
$ns connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 1.0 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 300.0 "finish"
proc finish {} {
global ns f
$ns flush-trace
close $f
exit 0
}
$ns run
