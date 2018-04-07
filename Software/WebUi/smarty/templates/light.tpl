{include "header.tpl"}

<script type="text/javascript">

$(function() {

	
	$('#T1').timepicker({
		timeFormat: "hh:mm",
		showSecond: false,
		currentText: "Teraz",
		closeText: "Wybierz",
		timeOnlyTitle: "Wybierz czas",
		timeText: "Czas",
		hourText: "Godzina",
		minuteText: "Minuta",
		secondText: "Sekunda"
	});
	
	$('#T2').timepicker({
		timeFormat: "hh:mm",
		showSecond: false,
		currentText: "Teraz",
		closeText: "Wybierz",
		timeOnlyTitle: "Wybierz czas",
		timeText: "Czas",
		hourText: "Godzina",
		minuteText: "Minuta",
		secondText: "Sekunda"
	});
	
	$('#TL').timepicker({
		timeFormat: "hh:mm:ss",
		showSecond: true,
		currentText: "Teraz",
		closeText: "Wybierz",
		timeOnlyTitle: "Wybierz czas",
		timeText: "Czas",
		hourText: "Godzina",
		minuteText: "Minuta",
		secondText: "Sekunda"
	});	
	
	$("#SLIDE_PWM1").slider({
		slide: function(event, ui) { 
				document.getElementById('PWM1').value = ui.value.toFixed(1) + "%";
		},
		step: 5,
		min: 0,
		max: 100,
		value: {$CONFIG.light_pwm1|replace:'%':''}
	});	
	
	$("#SLIDE_PWM2").slider({
		slide: function(event, ui) { 
				document.getElementById('PWM2').value = ui.value.toFixed(1) + "%";
		},
		step: 5,
		min: 0,
		max: 100,
		value: {$CONFIG.light_pwm2|replace:'%':''}
	});		
});
</script>


<div id="dashboard">
<form action="light.php" method="post">
<table>
<tr><td>PWM1:</td><td><input type="text" readonly id="PWM1" name="PWM1" value ="{$CONFIG.light_pwm1|replace:'%':''}%"></td></tr>
<tr><td colspan=2><div id="SLIDE_PWM1" style="margin:10px;"></div></td></tr>
<tr><td>PWM2:</td><td><input type="text" readonly id="PWM2" name="PWM2" value ="{$CONFIG.light_pwm2|replace:'%':''}%"></td></tr>
<tr><td colspan=2><div id="SLIDE_PWM2" style="margin:10px;"></div></div></td></tr>
<tr><td>T1:</td><td><input type="text" name="T1" id="T1" value ="{$CONFIG.light_t1|utcdate_format:"%H:%M"}"></td></tr>
<tr><td>T2:</td><td><input type="text" name="T2" id="T2" value ="{$CONFIG.light_t2|utcdate_format:"%H:%M"}"></td></tr>
<tr><td>TL:</td><td><input type="text" name="TL" id="TL" value ="{$CONFIG.light_tl|utcdate_format:"%H:%M:%S"}"></td></tr>
<tr><td>Wyjście </td><td><select name="interface">
{foreach from=$interfaces item="interface"}
	{if $interface.interface_type==3}
		<!-- {if $interface.interface_icon}<img src="img/{$interface.interface_icon}">{/if} -->
		<option value="{$interface.interface_id}">{$interface.interface_name}</option>
	{/if}
{/foreach}
</select></td></tr>
</table>
<INPUT TYPE="image" SRC="img/submit.png" align="right">
</form>

</div>
<div id="dashboard">
<img src="img/light_pwm.svg" align="right"></img>
</div>

{include "footer.tpl"}