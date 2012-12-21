<?php
/*
 * AquaPi - sterownik akwariowy oparty o Raspberry Pi
 *
 * Copyright (C) 2012 Marcin Kr�l (lexx@polarnet.pl)
 *
 * This program is free software; you can redistribute it and/or modify
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

$smarty->assign('title', 'Zdarzenia systemowe');

$count=20;
$offset=0;

if(isset($_GET['offset']))$offset = $count*$_GET['offset'];

$r = $db->GetOne('select count(*) from log;'); 
$pages = ceil($r/$count);
$logs = $db->GetAll('select * from log order by time desc limit '.$count.' offset '.$offset.';');

$smarty->assign('time', date("H:i"));
$smarty->assign('temp', $temp);
$smarty->assign('heating', false);
$smarty->assign('day', false);
$smarty->assign('logs', $logs);
$smarty->assign('pages', $pages);
$smarty->display('logs.tpl');
?>
