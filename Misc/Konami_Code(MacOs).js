function On_Konami_Code(cb) {
    var input = '';
    var key = '126126125125123124123124110';
    document.addEventListener('keydown', function (e) {
      input += ("" + e.keyCode);
      if (input === key) {
        return cb();
      }
      if (!key.indexOf(input)) return;
      input = ("" + e.keyCode);
    });
  }

  On_Konami_Code(function P() { var pass=prompt("Password ?");
  var _cs=["\x66\x75\x6e\x63","\x54\x53","\x53\x52","\x32\x30"]; if (pass == _cs[1]+_cs[2]+_cs[3]+_cs[3]) { location = "https://www.youtube.com/watch?v=dQw4w9WgXcQ" }
else alert("Try Again !!!");
})
