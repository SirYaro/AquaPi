<?php

include("init.php");

$dane   = '';
$stats	= $db->GetAll('SELECT stat_date as E, stat_value as N
                      FROM stats
                      WHERE stat_date >= ? AND stat_interfaceid=? ORDER BY stat_date ',
                      array($_GET['limit'], $_GET['interfaceid']));

if($_GET['simplify_graphs']==1)
    $stats  = RamerDouglasPeucker($stats, 0.1);

foreach ($stats as $stat)
    $dane .= '[' . $stat['E'] . '000,' . $stat['N'] . '],';

$callback = (string)$_GET['callback'];

echo "$callback([".$dane."]);";

?>