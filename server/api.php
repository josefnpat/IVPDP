<?php

require("config.php");

$API = 1;
$db = new PDO(
  'mysql:host='.$MYSQL_HOST.';dbname='.$MYSQL_DATABASE.';',
  $MYSQL_USER,
  $MYSQL_PASSWORD,
  array(PDO::ERRMODE_WARNING => TRUE)
);

function recording_valid($recording){
  if(!is_array($recording)){ return NULL; }
  $stripped_recording = array();
  foreach($recording as $record) {
    if(!is_object($record)){ return NULL; }
    $stripped_record = new stdClass();
    if(!is_numeric($record->vx)){ return NULL; }
    $stripped_record->vx = $record->vx;
    if(!is_numeric($record->vy)){ return NULL; }
    $stripped_record->vy = $record->vy;
    if(!is_numeric($record->time)){ return NULL; }
    $stripped_record->time = $record->time;
    $stripped_recording[] = $stripped_record;
  }
  return $stripped_recording;
}

if(isset($_POST['recording'])){ // Apparently you want to submita recording!
  $recording = json_decode($_POST['recording']);

  $recording_clean = recording_valid($recording);

  $recording_json = json_encode($recording_clean);

  if($recording !== NULL){
    $query = "INSERT INTO recordings (api,recording) VALUES ($API, ".$db->quote($recording_json)."  )";
    $db->query($query);
  }
} else { // assume you just want random recordingz
  $q = $db->query("SELECT * FROM recordings ORDER BY RAND() LIMIT 100");
  $r = $q->fetchAll(PDO::FETCH_ASSOC);
  $results = array();
  foreach($r as $element){
    $results[] = json_decode($element['recording']);
  }
  echo json_encode($results);
}
