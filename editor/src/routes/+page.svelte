<script lang="ts">
    import Notes from "$comp/Notes.svelte";
    import { exportSong, importSong } from "$lib/io";
    import { onMount } from "svelte";
    import WaveSurfer from "wavesurfer.js";

    let soundFile: FileList;
    let importFile: FileList;
    let wavesurfer: WaveSurfer;

    let songLayout: SongLayout;

    let delay: number = 0;
    let bpm: number = 120;
    let author: string = "";
    let name: string = "";
    let currentTime: number = 0;

    let songFileUrl: string = "";

    onMount(() => {
        wavesurfer = WaveSurfer.create({
            container: "#wave",
        });
    });

    $: loadNewSound(soundFile);
    $: loadNewProject(importFile);

    async function loadNewProject(importFile: FileList) {
        if (!importFile) return;
        if (importFile.length !== 1) return;
        console.log("load project file");
        let { data, music } = await importSong(importFile[0]);
        if (wavesurfer) wavesurfer.destroy();
        songFileUrl = music;
        wavesurfer = WaveSurfer.create({
            container: "#wave",
            url: music,
        });
        wavesurfer.on("timeupdate", timeUpdate);
        songLayout = data;
        bpm = songLayout.sections[0].bpm;
        author = songLayout.author;
        name = songLayout.name;
        delay = songLayout.delay;
    }

    function loadNewSound(soundFile: FileList) {
        if (!soundFile) return;
        if (soundFile.length == 1) {
            console.log("sound file loaded", soundFile[0]);
            if (wavesurfer) wavesurfer.destroy();

            songFileUrl = URL.createObjectURL(soundFile[0])
            wavesurfer = WaveSurfer.create({
                container: "#wave",
                url: songFileUrl,
            });
            wavesurfer.on("timeupdate", timeUpdate);

            wavesurfer.on("decode", (time) => {
                songLayout = {
                    delay,
                    sections: [
                        {
                            bpm,
                            end: Math.ceil(time * 1000) / 1000,
                            start: 0,
                            notes: {
                                lb: new Set<number>(),
                                lc: new Set<number>(),
                                ll: new Set<number>(),
                                lt: new Set<number>(),
                                rb: new Set<number>(),
                                rc: new Set<number>(),
                                rr: new Set<number>(),
                                rt: new Set<number>(),
                            },
                        },
                    ],

                    author,
                    name,
                };
            });
            name = soundFile[0].name.substring(0, soundFile[0].name.length - 4);
        }
    }

    function onKeyDown(event: KeyboardEvent) {
        // TODO: use number keys to jump between sections?

        switch (event.key) {
            case " ":
                wavesurfer.playPause();
                break;
        }
    }

    function timeUpdate(time: number) {
        currentTime = time;
    }
    function exportSongPage() {
        exportSong(songLayout, songFileUrl);
    }

    function updateValues() {
        songLayout.author = author;
        songLayout.delay = delay;
        songLayout.name = name;
        songLayout.sections[0].bpm = bpm;
        songLayout = songLayout;
    }

    function soundControl(action: string) {
        if (!wavesurfer) return;
        switch (action) {
            case "toggle":
                wavesurfer.playPause();
                break;
            case "start":
                wavesurfer.setTime(0);
                break;
            case "end":
                wavesurfer.setTime(wavesurfer.getDuration());
                break;
        }
    }
</script>

<svelte:head>
    <title>Booty Hero Creation Page</title>
</svelte:head>

<svelte:window on:keypress={onKeyDown} />

<label for="newSound">Soundfile for new project (.mp3)</label><input
    id="newSound"
    name="newSound"
    accept=".mp3"
    type="file"
    bind:files={soundFile}
/>
<label for="import">Import existing project (.booty)</label><input
    id="import"
    name="import"
    accept=".booty"
    type="file"
    bind:files={importFile}
/>

<div id="songSettings">
    <label for="bpm">bpm</label>
    <input
        type="number"
        name="bpm"
        id="bpm"
        bind:value={bpm}
        on:change={updateValues}
    />
    <label for="delay">delay</label>
    <input
        type="number"
        name="delay"
        id="delay"
        bind:value={delay}
        on:change={updateValues}
    />
    <label for="author">author</label>
    <input
        type="text"
        name="author"
        id="author"
        bind:value={author}
        on:change={updateValues}
    />
    <label for="name">name</label>
    <input
        type="text"
        name="name"
        id="name"
        bind:value={name}
        on:change={updateValues}
    />
</div>

<div id="wave"></div>
<div id="sound-control">
    <button on:click={() => soundControl("start")}>&lt;|</button>
    <button on:click={() => soundControl("toggle")}
        >Play/Pause (spacebar)</button
    >
    <button on:click={() => soundControl("end")}>|&gt;</button>
</div>
{#if songLayout}
    <Notes bind:layout={songLayout} bind:time={currentTime}></Notes>
    <button on:click={exportSongPage}>Export</button>
{/if}
