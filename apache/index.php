<?php
echo '<html>',"\n";
echo '  <head>',"\n";
echo '    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />',"\n";
echo '    <title>SDR-AMP</title>',"\n";
echo '    <style type="text/css" media="screen"></style>',"\n";
echo '  </head>',"\n";
echo '  <body style="background-image: url(\'/background-cool-blue.webp\'); background-repeat: no-repeat; background-attachment: fixed; background-size: 100% 100%;">',"\n";
echo '    <table id="ServerManagementTable" style="border-collapse: collapse;font-family: Verdana,sans-serif;">',"\n";
echo '    <tr style="border-bottom: 1px solid #ddd;">',"\n";
echo '      <th style="text-align: left;padding-left:10px;padding-right:10px;">Server management :</th>',"\n";
echo '      <th style="text-align: left;padding-left:10px;padding-right:10px;">',"\n";
echo '        <a href=/shell/server/ target="_blank" rel="noopener noreferrer">ssh</a>',"\n";
echo '      </th>',"\n";
echo '      <th style="text-align: left;padding-left:10px;padding-right:10px;">',"\n";
echo '        <a href=http://example.com:20001/ target="_blank" rel="noopener noreferrer">IceCast</a>',"\n";
echo '      </th>',"\n";
echo '      <th style="text-align: left;padding-left:10px;padding-right:10px;">',"\n";
echo '        <a href=/omv/ target="_blank" rel="noopener noreferrer">NAS</a>',"\n";
echo '      </th>',"\n";
echo '      <th style="text-align: left;padding-left:10px;padding-right:10px;">',"\n";
echo '        <a href=/shell/nas/ target="_blank" rel="noopener noreferrer">NAS (ssh)</a>',"\n";
echo '      </th>',"\n";
echo '      <th style="text-align: left;padding-left:10px;padding-right:10px;">',"\n";
echo '        <a href=/data/ target="_blank" rel="noopener noreferrer">Archive</a>',"\n";
echo '      </th>',"\n";
echo '    </tr>',"\n";
echo '    </table>',"\n";
echo ' <br>';
echo '    <table id="sensorsTable" style="border-collapse: collapse;font-family: Verdana,sans-serif;">',"\n";
echo '    <tr style="border-bottom: 1px solid #ddd;">',"\n";
echo '      <th style="text-align: left;padding-left:10px;padding-right:10px;">Sensor Name</th>',"\n";
echo '      <th style="text-align: left;padding-left:10px;padding-right:10px;">Listen address</th>',"\n";
echo '      <th style="text-align: left;padding-left:10px;padding-right:10px;">Listen now</th>',"\n";
echo '      <th style="text-align: left;padding-left:10px;padding-right:10px;">OpenWebRX</th>',"\n";
echo '      <th style="text-align: left;padding-left:10px;padding-right:10px;">Management</th>',"\n";
echo '    </tr>',"\n";
$SensorNames = shell_exec("curl -s http://127.0.0.1:20001/status-json.xsl | jq -r 'getpath([\"icestats\",\"source\"])' | grep server_name | grep -o \":.*\" | grep -o \"\\\".*\\\"\" | sed -e 's|[\"'\\'']||g'");
$SensorURLs = shell_exec("curl -s http://127.0.0.1:20001/status-json.xsl | jq -r 'getpath([\"icestats\",\"source\"])' | grep listenurl | grep -o \":.*\" | grep -o \"\\\".*\\\"\" | sed -e 's|[\"'\\'']||g'");
$SensorNamesA = explode("\n",$SensorNames);
$SensorURLsA = explode("\n",$SensorURLs);
for($i = 0; $i < count($SensorNamesA); $i++)
  if(($SensorNamesA[$i]<>"")&&($SensorURLsA[$i]<>""))
    {
      echo '    <tr style="border-bottom: 1px solid #ddd;">',"\n";
      echo '      <td style="text-align: left;padding-left:10px;padding-right:10px;">' . $SensorNamesA[$i] . '</td>',"\n";
      echo '      <td style="text-align: left;padding-left:10px;padding-right:10px;">',"\n";
      echo '        <a href=' . $SensorURLsA[$i] . '>' . $SensorNamesA[$i] . '</a>',"\n";
      echo '      </td>',"\n";
      echo '      <td style="text-align: left;padding-left:10px;padding-right:10px;">',"\n";
      echo '        <audio controls src="' . $SensorURLsA[$i] . '" type="audio/mpeg"></audio>',"\n";
      echo '      </td>',"\n";
      echo '      <td style="text-align: left;padding-left:10px;padding-right:10px;">',"\n";
      echo '        <a href="/OpenWebRX/' . $SensorNamesA[$i] . '/" target="_blank" rel="noopener noreferrer">' . $SensorNamesA[$i],"\n";
      echo '      </td>',"\n";
      echo '      <td style="text-align: left;padding-left:10px;padding-right:10px;">',"\n";
      echo '        <a href="/shell/' . $SensorNamesA[$i] . '/" target="_blank" rel="noopener noreferrer">' . $SensorNamesA[$i] . ' (ssh)',"\n";
      echo '      </td>',"\n";
      echo '    </tr>',"\n";
    }
echo '    </table>',"\n";
echo '  </body>',"\n";
echo '</html>';
?>
