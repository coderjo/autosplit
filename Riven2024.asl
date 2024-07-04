
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
	
	if(MD5Hash == "7C60B0A72F70178F3B94B34E034D2179") {
		version = "1.0.0(e3549-p25334)"; // steam
	} else if(MD5Hash == "9064284A7FCB34B3F48BB46D924A3A04") {
		version = "1.1.0(e3585-p25462)"; // steam
	} else {
		print("version not implemented. MD5Hash: " + MD5Hash.ToString());
		version = "Unknown Version";
	}
	
	print("version is: " + version);
}

isLoading
{
	// currently only detects "static" loading (book icon, entering starry expanse)
	// does not remove "dynamic" loading such as tram rides or leaving starry expanse
    return ( (current.playState & 0x1) != 0 );
}

