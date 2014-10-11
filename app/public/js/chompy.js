"#btnStream".onClick(function(event) {
  $('stream').html('');
  var source = new EventSource('/stream');
  source.onmessage = function(e) {
    console.log("Data received: " + e.data);
    $('stream').append(e.data);
  };
  source.addEventListener('close', function(e) { console.log('Connection Close Requested.'); source.close(); }, false);
  source.onclose = function(e) { console.log("Connection Closed."); };
});
