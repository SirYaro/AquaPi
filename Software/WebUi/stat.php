<?php
/*
 * AquaPi - sterownik akwariowy oparty o Raspberry Pi
 *
 * Copyright (C) 2012 Marcin Król (lexx@polarnet.pl)
 *
 * This program is free software; you can redistribute it AND/or modify
 * it under the terms of the GNU General Public License Version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
 * USA.
 *
 * $Id:$
 */
 
include("init.php");

$smarty->assign('title', 'Statystyki');

if(array_key_exists('limit', $_GET))
    switch ($_GET['limit'])
    {
	case 'week':
		    $limit = time() - (7 * 24 * 60 * 60);
	    break;
	case 'month':
		    $limit = time() - (31 * 24 * 60 * 60);
	    break;
	case 'no_limit':
		    $limit = 0;
	    break;
	default:
		    $limit = time() - (24 * 60 * 60);
    }
else
    $limit = time() - (24 * 60 * 60);
    
$stat	= $db->GetAll('SELECT time_st, temp, sensor_id FROM temp_stats WHERE time_st >= ? AND temp>-50 ORDER BY time_st', array($limit));
$sensors= array_values(array_msort(
				    $db->GetAll('SELECT * FROM sensors WHERE sensor_id
						IN(SELECT distinct sensor_id FROM temp_stats WHERE time_st >= ? AND temp>-50 ORDER BY time_st)
						AND sensor_deleted=0 AND sensor_draw=1', array($limit))
				    , array('sensor_id'=>SORT_ASC)
				 ));

//new dBug($sensors);

//$first	= reset($stat)['time_st'];
//$last	= end($stat)['time_st'];
$first	= reset($stat);
$first	= $first['time_st'];
$last	= end($stat);
$last	= $last['time_st'];

foreach ($stat as $index=>$value)
{
	$date=floor($value['time_st']/60)*60;
	$temperature[$date]['year'] = date("Y", $date);
	$temperature[$date]['month'] = date("n", $date)-1;
	$temperature[$date]['day'] = date("j", $date);
	$temperature[$date]['hour'] = date("H", $date);
	$temperature[$date]['minutes'] = date("i", $date);
	$temperature[$date][$value['sensor_id']] = $value['temp'];
	//$temperature[$value['sensor_id']][]=array(floor($value['time_st']/60)*60 => $value['temp']);
}
//new dBug($temperature);
$out_names	= $db->GetAll('SELECT distinct(event) FROM output_stats WHERE time_st >= ? ORDER BY time_st', array($limit));
$stat		= $db->GetAll('SELECT time_st,state,event FROM output_stats WHERE time_st >= ? ORDER BY time_st', array($limit));

$i = 0;
foreach ($out_names as $name)
{
	$outputs_names[$name['event']]['id'] = $i;
	$outputs_names[$name['event']]['prev'] = null;
	$outputs_names[$name['event']]['fname'] = $db->GetOne("SELECT fname FROM devices WHERE device = ?", array($name['event']));
	$i++;
}

$i = 0;
foreach ($outputs_names as $key => $out_name)
{
	$ini_val = $db->GetOne('SELECT state FROM output_stats WHERE time_st < ? AND event = ? ORDER BY time_st DESC LIMIT 1', array($limit, $key));
	if ($ini_val == null) {$ini_val = 0; }
	$outputs_names[$key]['prev'] = $ini_val;
	$outputs_arr[$first][$i] = $ini_val;
	$i++;
}

foreach ($stat as $value)
{
	if ($outputs_names[$value['event']]['prev'] != $value['state']) {
		$outputs_arr[$value['time_st']-1][$outputs_names[$value['event']]['id']] = $outputs_names[$value['event']]['prev'];
	}
	$outputs_arr[$value['time_st']][$outputs_names[$value['event']]['id']] = $value['state'];
	$outputs_names[$value['event']]['prev'] = $value['state'];
}

$i = 0;
foreach ($outputs_names as $key => $out_name)
{
	$outputs_arr[$last][$i] = $out_name['prev'];
	$i++;
}

$smarty->assign('temperature', $temperature);
$smarty->assign('sensors', $sensors);
$smarty->assign('outputs_arr', $outputs_arr);
$smarty->assign('outputs_names', $outputs_names);
$smarty->display('stat.tpl');
?>
