import QtQuick 1.1
import qb.components 1.0
import qb.base 1.0
import HttpRequest 1.0
import "dashticz.js" as DashticzJS 


App {
	id: dashticzApp
	
	property url trayUrl : "DashticzTray.qml"
	property url tileUrl : "./DashticzTile.qml"
	property url switchesTileUrl : "./DashticzSwitchesTile.qml"
	property url ovTileUrl : "./DashticzOvTile.qml"
	
	property url thumbnailIcon: "./drawables/dashticzIcon.png"
	property url tileIcon: "./drawables/dashticzTile.png"
	
	property url dashticzScreenUrl : "DashticzScreen.qml"
	property url dashticzSwitchesUrl : "DashticzSwitches.qml"
	property url dashticzSettingsUrl : "DashticzSettings.qml"
	property url dashticzOvUrl : "DashticzOv.qml"
	
	property DashticzSettings dashticzSettings
	property bool noApps: false
	property bool firstLoad : true
	property bool settingsLoaded: false
	property bool runningFromTile: false
	property variant tileIDXList: []
	
	property variant devices : []
	property variant devicesPerIDX : []
	property bool devicesReceived: false
	property bool loadDevices: false
	
	property variant departures : []
	property bool ovReceived: false
	
	property variant settings: { 
		"domoticzHost": "",
		"domoticzPort": "",
		"domoticzUsername" : "",
		"domoticzPassword" : "",
		"domoticzTileIDX" : "",
		"ovHalte" : "",
	}

	function init() {
		registry.registerWidget("screen", dashticzScreenUrl, this);
		registry.registerWidget("screen", dashticzSettingsUrl, this, "dashticzSettings");
		
		registry.registerWidget("screen", dashticzSwitchesUrl, this, "dashticzSwitches");
		//registry.registerWidget("tile", switchesTileUrl, this, null, {thumbLabel: "Schakelaars", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});

		registry.registerWidget("screen", dashticzOvUrl, this, "dashticzOv");
		//registry.registerWidget("tile", ovTileUrl, this, null, {thumbLabel: "OV", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
		
		registry.registerWidget("systrayIcon", trayUrl, this, "dashticzTray");
		//registry.registerWidget("tile", tileUrl, this, null, {thumbLabel: "Dashticz", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
	}

	function loadSettings()  {
		var settingsFile = new XMLHttpRequest();
		settingsFile.onreadystatechange = function(){
			if (settingsFile.readyState == XMLHttpRequest.DONE) {
				if (settingsFile.responseText.length > 0)  {
					settingsLoaded=true
					
					var temp = JSON.parse(settingsFile.responseText);
					for (var setting in settings) {
						if (temp[setting] === undefined)  { temp[setting] = settings[setting]; } // use default if no saved setting exists
					}
					settings = temp;
					tileIDXList = settings.domoticzTileIDX.split(',')
					
					if(loadDevices){
						getDevices();
					}
				}
			}
		}
		settingsFile.open("GET", "file:///HCBv2/qml/apps/dashticz/dashticz.settings", true);
		settingsFile.send();
	}
	
	function domoticzCall(url,onoff) {
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET", "http://"+settings.domoticzHost+":"+settings.domoticzPort+"/json.htm?username="+settings.domoticzUsername+"&password="+settings.domoticzPassword+"&"+url, true);
		xmlhttp.send();
	}
	
	function getDevices() {
		console.log("Dashticz GET Devices");
		devicesReceived=false
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange=function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				var res = JSON.parse(xmlhttp.responseText);
				devices = res["result"]
				for (var i = 0; i < devices.length; i++){
					devicesPerIDX[devices[i]["idx"]] = devices[i]
				}
				devicesReceived = true;
		
			}
		}
		xmlhttp.open("GET", "http://"+settings.domoticzHost+":"+settings.domoticzPort+"/json.htm?username="+settings.domoticzUsername+"&password="+settings.domoticzPassword+"&type=devices&favorite=1&filter=all&used=true&order=Name", true);
		xmlhttp.send();
	}
	
	function getOV(){
		ovReceived=false
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange=function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				var res = JSON.parse(xmlhttp.responseText);
				departures = res["tabs"][0]["departures"]
				ovReceived = true;
			}
		}
		xmlhttp.open("GET", "http://dashticz.nl/ov/ov.php?station="+settings.ovHalte, true);
		xmlhttp.send();
	}

}
