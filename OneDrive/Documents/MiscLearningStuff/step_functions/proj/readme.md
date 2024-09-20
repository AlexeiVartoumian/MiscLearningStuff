

docs for v4 sentiment step func:
accepted input :
{
  "fileName": "filename.audioextenion",
  "fileExtension": "audio_extension_without_dot"
}
current imple does not handle spaces for filename
as splitting string down the line should follow this format
Council_Meeting_SpringField_USA_July_26_2022.mp3

sentiment analysis is currently limited to 5000 bytes. either look at JSon payload to see if there is value for byte amount or create lambda to measure. 
then a parallel state can be used here to handle.

doc for summarizer:

accepts as input like so
{
  "input": {
    "key": "Council_Meeting_SpringField_USA_July_26_2022.json"
  }
}

invokes claude 3.0 because model is being invoked from london region.
should investigate how to connect the state machine to north virgina. maybe keep it modular and link the two state machines somewhow.
want north virginia because claude 3.5 is avalailble there.
also the file renaming needs work as its outputting a txt ile should be json

also look to link the two state machines