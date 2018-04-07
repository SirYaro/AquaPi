<!-- demo jak wyświetlić wszystkie jeszcze nie ustawione wejścia i wyjścia -->
<div id="dashboard">
<h3>Dodaj nowe wejście:</h3>
<script>
function ChangeInput()
{
	var devices = new Array();
	{foreach from=$device_list->devicelist->device item="device"}
	devices.push(Array('{$device->address}','{$device->description}','{$device->fully_editable_address}', '{$device->prompt}'));
	{/foreach}

	var length = devices.length;
	var e = document.getElementById("InputAddressSelector").value;
	var FullyEditableVisible = false;
	
	for (var i = 0; i < length; i++)
	{
		var item = devices[i];
		if (item[0] == e) 
		{
			if (item[2] == 'yes') FullyEditableVisible = true;
			document.getElementById('FullyEditablePrompt').innerHTML = item[3];
		}
	}

	if (FullyEditableVisible) 
	{
		document.getElementById('FullyEditable').disabled = false;
	}
	else
	{
		document.getElementById('FullyEditable').value = "";
		document.getElementById('FullyEditable').disabled = true;
	}
	
}
function ChangeIcon()
{
	var icon = document.getElementById("InputIconSelector").value;
	document.getElementById("icon-prev").setAttribute("src","img/" + icon);

}
window.onload = load;

function load()
{
	ChangeInput();
	ChangeIcon();
}
</script>
<form action="settings.php?action=add_input" method="post">
<table>
<tr><td>Przyjazna nazwa</td><td><input name="InputFriendlyName" style="width:200px"></td></tr>
<tr><td>Adres sprzętowy</td><td>
<select name="InputAddressSelector" id="InputAddressSelector" onchange="ChangeInput()" style="width:200px">
{foreach from=$device_list->devicelist->device item="device"}
	{if ($device->input == 'yes') && !($device->configured == 'yes')}
		<option value="{$device->address}">{$device->description}</option>
	{/if}
{/foreach}
</select></td></tr>
<tr><td><span id="FullyEditablePrompt">Dodatkowy adres</span></td><td><input name="FullyEditable" id="FullyEditable" style="width:200px"><br/></td></tr>
<tr><td>Ikona<img src="img/alert.png" id="icon-prev"style="float:right"></td><td>
<select name="InputIconSelector" id="InputIconSelector" onchange="ChangeIcon()" style="width:200px">
	{foreach $icons item=icon}
	<option class="imagebacked" style="background-image:url(img/{$icon});">{$icon}</option>
	{/foreach}
</select></td></tr>
<tr><td>Jednostka</td><td>
<select name="InputUom" style="width:200px">
	<option value="none">Brak</option>
	{foreach from=$units item=unit}
	<option value="{$unit.unit_id}">{$unit.unit_name}</option>
	{/foreach}
</select></td></tr>
</table>
<INPUT TYPE="image" SRC="img/submit.png" align="right">
</form>
</div>

<!-- koniec dema -->