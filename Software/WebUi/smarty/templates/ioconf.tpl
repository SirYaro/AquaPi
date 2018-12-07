{include "header.tpl"}
<script>
function confirmLink(theLink, message)
{
	var is_confirmed = confirm(message);

	if (is_confirmed) {
		theLink.href += '&is_sure=1';
	}
	return is_confirmed;
}

</script>

        <div class="content mt-3">
            <div class="animated fadeIn">
                <div class="row">
                    <div class="col-lg-12">
						<form action="ioconf.php" method="post" class="form-horizontal">
							<section class="card">
                                <div class="card-header">
                                    <strong class="card-title" v-if="headerText">Skonfigurowane urządzenia</strong>
                                </div>							
								<div>
									<table id="bootstrap-data-table-export" class="table">
										<thead>
											<tr>
												<th colspan=2>Ikona</th>
												<th>Nazwa</th>
												<th>Adres</th>
												<th>Kolor</th>
												<th>Tryb</th>
												<th>&nbsp;</th>
											</tr>
										</thead>
										<tbody>
										{foreach from=$devices item="device"}
											<tr>
												<td><img src="img/devices/{$device.interface_icon}" id="icon-prev-{$device.interface_id}"></td>
												<td>
													<!-- <input name="interfaces[{$device.interface_id}][img]" class="IconInputId{$device.interface_id}" value="" type="hidden"></input> -->
													<select name="interfaces[{$device.interface_id}][img]" id="IconSelectorId{$device.interface_id}" class="form-control" onchange="document.getElementById('icon-prev-{$device.interface_id}').setAttribute('src','img/devices/' + document.getElementById('IconSelectorId{$device.interface_id}').value);">
														{foreach $icons item=icon}
														<option data-imagesrc="img/devices/{$icon}"{if $icon==$device.interface_icon} selected{/if}>{$icon}</option>
														{/foreach}
													</select>	
												</td>
												<td><input name="interfaces[{$device.interface_id}][name]" value="{$device.interface_name}" class="form-control"></input></td>
												<td>{$device.interface_address}</td>
												<td><input type="color" value="#{$device.interface_htmlcolor}" name="interfaces[{$device.interface_id}][htmlcolor]" class="form-control"></td>
												<td>{if $device.interface_type==1}Wejście{elseif $device.interface_type==2}Wyjście binarne{elseif $device.interface_type==3}Wyjście PWM{/if}</td>
												<td>
													<a href="?action=delete&device_id={$device.interface_id}" onClick="return confirmLink(this,'Czy jesteś pewien, że chcesz usunąć to urządzenie?');" class="btn btn-danger btn-sm">
														<i class="fa fa-times"></i> Usuń
													</a>
												</td>
											</tr>
										{/foreach}
										</tbody>
									</table>
								</div>
								<div class="card-footer">
									<button type="submit" class="btn btn-primary btn-sm">
										<i class="fa fa-save"></i> Zapisz
									</button>
									<button type="reset" class="btn btn-danger btn-sm">
										<i class="fa fa-ban"></i> Reset
									</button>									
								</div>								
							</section>
						</form>
                    </div>
				</div>
			</div>
		</div>
								
        <div class="content mt-3">
            <div class="animated fadeIn">
                <div class="row">
                    <div class="col-lg-12">
						<form action="ioconf.php?action=add" method="post" class="form-horizontal">
							<section class="card">
                                <div class="card-header">
                                    <strong class="card-title" v-if="headerText">Dodaj nowe wejście lub wyjście</strong>
                                </div>							
								<div class="card-body card-block">
<script>
function ChangeInput()
{
	var devices = new Array();
	{foreach from=$device_list->devicelist->device item="device"}
	devices.push(Array('{$device->address}','{$device->description}','{$device->fully_editable_address}', '{$device->prompt}', '{$device->input}', '{$device->output}', '{$device->pwm}'));
	{/foreach}

	var length = devices.length;
	var e = document.getElementById("InputAddressSelector").value;
	var FullyEditableVisible = false;
	
	for (var i = 0; i < length; i++)
	{
		var item = devices[i];
		if (item[0] == e) 
		{
			if (item[2] == 'yes') {
				document.getElementById('FullyEditable').disabled = false;
				document.getElementById('FullyEditablePrompt').innerHTML = item[3];
			} else 	{
				document.getElementById('FullyEditable').value = "";
				document.getElementById('FullyEditable').disabled = true;
			}
			if (item[4] == 'yes') {
				document.getElementById('IOIn').disabled = false;

			} else {
				document.getElementById('IOIn').disabled = true;
			}
			if (item[5] == 'yes') {
				document.getElementById('IOOut').disabled = false;				
			} else {
				document.getElementById('IOOut').disabled = true;
			}			
			if (item[6] == 'yes') {
				document.getElementById('IOOutPWM').disabled = false;				
			} else {
				document.getElementById('IOOutPWM').disabled = true;
			}				
			if (item[5] == 'yes' && item [4] == 'no') document.getElementById('IOOut').checked = true;
			if (item[4] == 'yes' && item [5] == 'no') document.getElementById('IOIn').checked = true;
		}
	}
}

function ChangeIcon()
{
	var icon = document.getElementById("InputIconSelector").value;
	document.getElementById("icon-prev").setAttribute("src","img/devices/" + icon);

}
window.onload = load;

function load()
{
	ChangeInput();
	ChangeIcon();
}
</script>

									<div class="row form-group">
										<div class="col-2"><label for="InputFriendlyName" class=" form-control-label">Przyjazna nazwa</label></div>
										<div class="col-4"><input type="text" id="InputFriendlyName" name="InputFriendlyName" class="form-control"></div>
										<div class="col-2"><label for="InputAddressSelector" class=" form-control-label">Adres sprzętowy</label></div>
										<div class="col-4">
											<select name="InputAddressSelector" id="InputAddressSelector" onchange="ChangeInput()" class="form-control">
											{foreach from=$device_list->devicelist->device item="device"}
												{if ($device->input == 'yes') && !($device->configured == 'yes')}
													<option value="{$device->address}">{$device->description}</option>
												{/if}
											{/foreach}
											</select>
										</div>
									</div>
									<div class="row form-group">
										<div class="col-2"><label for="FullyEditable" class=" form-control-label" id="FullyEditablePrompt">Dodatkowy adres</label></div>
										<div class="col-4"><input type="text" id="FullyEditable" name="FullyEditable" class="form-control"></div>										
										<div class="col-2"><label for="InputIconSelector" class=" form-control-label">Ikona</label></div>
										<div class="col-1"><img src="img/alert.png" id="icon-prev"></div>
										<div class="col-3">
										<select name="InputIconSelector" id="InputIconSelector" onchange="ChangeIcon()" class="form-control">
											{foreach $icons item=icon}
											<option class="imagebacked">{$icon}</option>
											{/foreach}
										</select>
										</div>	
									</div>
									<div class="row form-group">
										<div class="col-2"><label for="InputModeSelector" class=" form-control-label">Ustaw jako</label></div>
										<div class="col-4">
											<select name="InputModeSelector" id="InputModeSelector" onchange="ChangeInput()" class="form-control">
												<option value="1" id="IOIn">Wejście</option>
												<option value="2" id="IOOut">Wyjście binarne</option>
												<option value="3" id="IOOutPWM">Wyjście PWM</option>
											</select>
										</div>
										<div class="col-2"><label for="htmlcolor" class=" form-control-label">Kolor</label></div>
										<div class="col-4"><input type="color" id="htmlcolor" name="htmlcolor" class="form-control"></div>						
									</div>
								</div>
								<div class="card-footer">
									<button type="submit" class="btn btn-primary btn-sm">
										<i class="fa fa-save"></i> Zapisz
									</button>
								</div>								
							</section>
						</form>
                    </div>
				</div>
			</div>
		</div>
	


{include "footer.tpl"}
