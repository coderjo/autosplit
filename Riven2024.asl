
state("Riven-Win64-Shipping", "1.0.0(e3549-p25334)")
{
	// ---- Load Removal Variables ----
	
	// playState -- 
	// 0 = game paused
	// 1 = game paused & loading
	// 256 = game running
	// 257 = game running & loading
	int playState : "Riven-Win64-Shipping.exe", 0x07CB9790, 0x1e0, 0xb24;
}

state("Riven-Win64-Shipping", "1.1.0(e3585-p25462)")
{
	// ---- Load Removal Variables ----
	
	// playState -- 
	// 0 = game paused
	// 1 = game paused & loading
	// 256 = game running
	// 257 = game running & loading
	int playState : "Riven-Win64-Shipping.exe", 0x07CBC790, 0x1e0, 0xb34;
	
	// 1 = loading during pause or dome transition
	int waitLoad  : "Riven-Win64-Shipping.exe", 0x081189A0, 0x5C0, 0x3B0;
	// bit [24] = riding in vehicle
	int moveFlags : "Riven-Win64-Shipping.exe", 0x07DA1260, 0x10, 0x470, 0x6C4;
	// 1 = dynamic loading done
	//int loadDone  : "Riven-Win64-Shipping.exe", 0x07F70450, 0x530;
	int loadDone  : "Riven-Win64-Shipping.exe", 0x7D855D4;
	// screen blanked while moving
	int moveBlank : "Riven-Win64-Shipping.exe", 0x07D485E0, 0, 0x8D0;
}

startup
{
	settings.Add("dynLoads", true, "Remove Dynamic Loads (supported on 1.1)");
}

init
{
	//i robbed this md5 code from CptBrian's RotN autosplitter
	//shoutouts to him
	byte[] exeMD5HashBytes = new byte[0];
	using (var md5 = System.Security.Cryptography.MD5.Create())
	{
		using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
		{
			exeMD5HashBytes = md5.ComputeHash(s); 
		} 
	}
	var MD5Hash = exeMD5HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
	//print("MD5Hash: " + MD5Hash.ToString()); //Lets DebugView show me the MD5Hash of the game executable, which is actually useful.
	
	vars.dynLoads = false;
	
	if(MD5Hash == "7C60B0A72F70178F3B94B34E034D2179") {
		version = "1.0.0(e3549-p25334)"; // steam
	} else if(MD5Hash == "9064284A7FCB34B3F48BB46D924A3A04") {
		version = "1.1.0(e3585-p25462)"; // steam
		vars.dynLoads = true;
	} else {
		print("version not implemented. MD5Hash: " + MD5Hash.ToString());
		version = "Unknown Version";
	}
	
	print("version is: " + version);
}

isLoading
{
	if(vars.dynLoads && settings["dynLoads"]) {
		// remove dynamic loads
		return (current.waitLoad == 1) || // removes loading during pause or in domes
		       //(((current.moveFlags & 0x01000000) == 0x01000000) && current.loadDone == 0); // remove loading in vehicles
		       (current.moveBlank == 1 && current.loadDone == 0); // remove loading in vehicles
	} else {
		// old method, remove when paused for loading
		return (current.playState & 0x1) != 0;
	}
}

