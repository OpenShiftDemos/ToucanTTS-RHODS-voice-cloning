# Voice Cloning and TTS with IMS-Toucan and Red Hat OpenShift Data Science

There has been a lot of advancement in generative AI, but not everything is
large language models (LLMs). Voice generation and text-to-speech have made
considerable advancements, too.

[Red Hat OpenShift Data
Science](https://www.redhat.com/en/technologies/cloud-computing/openshift/openshift-data-science)
or RHODS, for short, is a solution that allows organizations to standardize and
streamline the way they use Jupyter Notebooks, assisting data scientists with
experimentation as well as with producing serve-able models to run in
production. It is based on the upstream [Open Data Hub](https://opendatahub.io/)
community project.

[IMS-Toucan](https://github.com/DigitalPhonetics/IMS-Toucan) is a toolkit for
speech synthesis developed out of the Institute for Natural Language Processing
(IMS) at the University of Stuttgart in Germany. It provides a pure Python and
PyTorch way of doing things like fine-tuning synthesis models, which is a fancy
way of describing voice cloning.

As a motorsports enthusiast and gamer, I have spent a lot of time sim racing,
and the [CrewChief](https://thecrewchief.org/) application has proved
indispensable for many reasons. One common issue with Crew Chief is that the
main voice used in the application, Jim, is not a synthesised one. Jim Britton,
who developed the application, has recorded all of the audio that is stitched
together by CrewChief as it is delivered to the user.

In an effort to try to alleviate the load on Jim for recording the sounds of
names (used for personalization), I decided to attempt to clone Jim's voice in
order to be able to generate additional audio content.

**WARNING AND ACKNOWLEDGEMENT**
There are serious ethical considerations that come with the use of generative AI
technologies. Deep-fakes, misinformation, and other challenges abound. This
content is not presented as an endorsement of any nefarious uses of generative
AI. It is an experiment with the capabilities of a specific technology and was
done with permission of the voice's owner, Jim.

## Getting Started with Red Hat OpenShift Data Science
We have an instance of Red Hat OpenShift Data Science (RHODS) that was used for
these experiments. RHODS runs on top of OpenShift. The OpenShift environment
where RHODS is running is configured to allow auto-scaling of the cluster when
GPUs are requested.

The first step in the experiment is setting up a Data Science project in RHODS,
and then creating a Workbench that requests an instance with a GPU. Our data
sets are not particularly large, and these experiments predominantly rely on GPU
memory, so the "Small" container sized environment would suffice (2CPU, 8Gi of
memory max).

Persistent storage will be required to hold our data and allow us to shut down
the Workbench and come back to it later when we were not actively working.
While the files in question and the models are not tremendously large, we chose
to use around 40Gi of storage.

Note that, when using RHODS, the administrators who set up the environment can
configure the various sizes of containers, storage availablility, and more.

With the container configured and the workbench started, we now had access to a
JupyterLab environment and could begin our experiments. Or so we thought.

## Custom Notebook Images with RHODS
As text-to-speech requires audio libraries, we quickly encountered an issue
where the base notebook images provided in our environment didn't have any audio
libraries. Fortunately, RHODS makes it easy to create customized notebook images
to serve as the baseline for any experimentation.

The `Containerfile` in this repository defines a container image that starts 
from a CentOS Streams 9 base that was already created to work with RHODS and
adds the required espeak, libsnd, and portaudio components that were needed for
IMS-Toucan to work properly.

This [OpenDataHub contrib
repository](https://github.com/opendatahub-io-contrib/workbench-images/) has
links to and source files for various container images to be used with RHODS.
Depending on your target data science needs, there may be a good starting point
already available for you.

Once the container image was built, we asked a RHODS administrator to make it
available for us to use in the environment. Now we could finally get started.

## Cloning the Source Repositories
Once the JupyterLab environment is up and running, the first step is to clone the
Toucan and CrewChief repositories so that the metadata for the training can be
generated.

For IMS-Toucan, version 2.4 needs to be used, as v2.5 seemed to have issues with
the cloning, [reported in this GitHub issue](https://github.com/DigitalPhonetics/IMS-Toucan/issues/134).

Open a terminal tab inside of the JupyterLab environment, make sure that you are
in the default folder location, and clone the specific version of IMS-Toucan as
follows:

    cd
    git clone https://github.com/DigitalPhonetics/IMS-Toucan
    cd IMS-Toucan
    git checkout v2.4
    cd

Next, you will need to clone the CrewChief repository:

    git clone https://gitlab.com/mr_belowski/CrewChiefV4

You will also want to clone this repository, as it contains some modified files
for IMS-Toucan as well as a script to generate the metadata file needed for
Toucan's training process:

    git clone https://github.com/OpenShiftDemos/ToucanTTS-RHODS-voice-cloning

## Get the Files in Order
First, the three python files that are in this repository need to go into
specific places in the Toucan folder structure:

* `path_to_transcript_dicts.py` contains a Python function
  that knows how to parse the metadata file that you will generate. The metadata
  file is a combination of audio file filename and the text transcription of
  that same audio.

* `finetune_crewchief.py` is a copy of the example fine tuning script that
  IMS-Toucan provides, modified
  to use the dataset that you will generate

* `run_training_pipeline.py` is modified to add the new fine tuning option
  that was defined.

* `metadata-generator.sh` parses the existing metadata files that are already in
  the CrewChief repository and generates a new file for IMS-Toucan to use that
  contains only the correct audio files and transcripts needed to fine tune
  Jim's voice.

Copy the files into the necessary locations with the following commands:

    cd
    cp ~/ToucanTTS-RHODS-voice-cloning/finetune_crewchief.py IMS-Toucan/TrainingInterfaces/TrainingPipelines/
    cp ~/ToucanTTS-RHODS-voice-cloning/path_to_transcript_dicts.py IMS-Toucan/Utility/
    cp ~/ToucanTTS-RHODS-voice-cloning/run_training_pipeline.py IMS-Toucan/
    cp ~/ToucanTTS-RHODS-voice-cloning/audio_generator.py IMS-Toucan/

## Generate the Metadata CSV file
Change your directory location in the terminal to the necessary folder in the
CrewChief structure:

    cd ~/CrewChiefV4/CrewChiefV4/sounds

Then, execute the metadata generator script:

     bash ~/ToucanTTS-RHODS-voice-cloning/metadata-generator.sh

**Note**: You may see an error like:

    rm: cannot remove 'metadata.csv': No such file or directory

This is OK. It is because the script is trying to remove any previous instance
of the metadata file before it generates it freshly. The metadata generator
script will not produce any output. However, you can verify that it produced the
desired output with the following command:

    tail metadata.csv

You'll see something like the following:

    voice/frozen_order/line_up_single_file_behind/1|line up single-file behind
    voice/frozen_order/line_up_single_file_behind/2|line up single-file behind
    voice/frozen_order/line_up_single_file_behind/3|line up single-file behind
    voice/frozen_order/line_up_single_file_behind/4|line up single-file behind
    voice/frozen_order/line_up_single_file_behind/5|line up single-file behind
    voice/frozen_order/safetycar_out_eu/1|the safety car is out
    voice/frozen_order/safetycar_out_eu/2|the safety car's out
    voice/frozen_order/safetycar_out_eu/3|safety car is out
    voice/frozen_order/safetycar_out_eu/4|the safety car's out
    voice/frozen_order/safetycar_out_eu/5|the safety car is out

This is in the desired format of `PATH-TO-FILE|transcribed text`, where a pipe (`|`) is the field delimeter.

## Install Requirements
First, you must install the Python dependencies/requirements. It is a feature of
RHODS that every time you restart your workbench you must reinstall the Python
requirements. This helps to guarantee a known state.

    cd ~/IMS-Toucan
    pip install -r requirements.txt
    # deal with https://github.com/DigitalPhonetics/IMS-Toucan/issues/138
    pip install torch torchvision torchaudio

**NOTE:** In certain situations (including this one), pytorch can attempt to use
*more shared memory
than is available to it, causing a crash. Please see the following (release
notes)[https://access.redhat.com/documentation/en-us/red_hat_openshift_data_science/1/html-single/release_notes/index#known-issues_relnotes]
for RHODS regarding how to configure additional shared memory for your notebook.

## Download the Base Models
IMS-Toucan has pre-trained models that you will use to fine-tune. Make sure to download them:

    python run_model_downloader.py

## Small fixes
The file `worker-device.patch` is provided to apply small fixes to the
IMS-Toucan codebase. For one, there is a tweak to calculate the number of
workers based on the number of CPU cores present (instead of a blanket default)
and there is a fix for [this particular
issue](https://github.com/DigitalPhonetics/IMS-Toucan/issues/88) which needs to
be backported to v2.4.

You can apply the patch as follows:

    cd ~/IMS-Toucan
    git apply ~/ToucanTTS-RHODS-voice-cloning/worker-device.patch

## Run the Training
Once you have downloaded the models, you can run the training:

    cd ~/IMS-Toucan
    python run_training_pipeline.py --gpu_id 0 crewchief_jim

Then, wait around 30 minutes with a small-ish GPU and reasonable-speed disks.

There may be some small errors along the way about audio length, complex
tensors, or warnings about removing datapoints. You can safely ignore these. If
you get to see something like:

    Epoch:              9
    Total Loss:         0.9669371968147739
    Cycle Loss:         0.28769828969200184
    Time elapsed:       31 Minutes
    Steps:              6705

With no egregious errors or exits, you were successful!

## Run weight averaging
There is a provided Python script that will average some things together and
produce a `best` model. Run that script with:

    python run_weight_averaging.py

The end result should be that you now have a `best.pt` in the right model
folder:

    ls -l Models/PortaSpeech_CrewChief_Jim/
    total 2092956
    -rw-r--r--. 1 1002460000 1002460000 133898421 Jun  1 16:19 best.pt
    -rw-r--r--. 1 1002460000 1002460000 401853032 Jun  1 15:40 checkpoint_3725.pt
    -rw-r--r--. 1 1002460000 1002460000 401853032 Jun  1 15:43 checkpoint_4470.pt
    -rw-r--r--. 1 1002460000 1002460000 401853032 Jun  1 15:47 checkpoint_5215.pt
    -rw-r--r--. 1 1002460000 1002460000 401853032 Jun  1 15:50 checkpoint_5960.pt
    -rw-r--r--. 1 1002460000 1002460000 401853032 Jun  1 15:54 checkpoint_6705.pt
    drwxr-sr-x. 2 1002460000 1002460000      4096 Jun  1 15:54 spec_after
    drwxr-sr-x. 2 1002460000 1002460000      4096 Jun  1 15:54 spec_before

## Generate Some Voice
Now you are ready to generate some audio from your freshly trained model!

    python audio_generator.py --text "this, is jim, from crew chief, powered by red hat openshift data science" --outfile thisjim.wav

You might think "that sounds terrible!" Go back and listen to some of the
original audio samples, though. The reality is that the original audio has
Audacity filters applied to make it sound like a person speaking over an analog
walkie-talkie. It's scratchy, not great input. The generated output also sounds
scratchy and like someone talking over a radio. The model training process
"faithfully" reproduced the audio filter, too, in a way.

If we had clean audio of Jim pre-filter to train the model, things would have
been much better. But this model does sufficiently well for getting the job done
for our purposes.

Thanks, Jim!