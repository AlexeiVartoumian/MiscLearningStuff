<?php
include "chaosmonkey.php";



//monkeyCurl("linkName=Software+and+Programming+III");


for ($i = 0 ; $i <= 100; $i++){
    monkeyCurl("linkName=Software+and+Programming+III");
    monkeyCurl("linkName=Computer+Systems+and+Archtecture");
    monkeyCurl("linkName=Software+and+Programming+III");
}
?>