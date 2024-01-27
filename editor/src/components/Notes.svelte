<script lang="ts">
    import Row from "./Row.svelte";
    export let layout: SongLayout;
    export let time: number;

    export function setNoteThroughKeys(time: number, note: string) {
        let section;
        for(let s of layout.sections){
            if(s.start <= time && s.end >= time){
                section = s;
                break;
            }
        }
        if(!section) return;
        let duration = section.end - section.start;
        let notesAmount = Math.floor(duration / noteDuration);
        let sectionTime = time - section.start;
        let index = Math.floor(sectionTime / noteDuration);
        toggleNote(new CustomEvent("anything", {detail: {note, index}}), section);
    }

    let notesDiv: HTMLDivElement;

    let notesPerBeat: number = 8;
    let noteWidth: number = 10;
    $: noteDuration = ((1 / layout.sections[0].bpm) * 60) / notesPerBeat;

    $: playheadPosition = Math.max(
        0,
        ((time - layout.delay / 1000) / noteDuration) * noteWidth,
    );
    $: scrollTo(playheadPosition);

    function scrollTo(position: number) {
        if (!notesDiv) return;
        notesDiv.scrollLeft = position - 100;
    }

    function toggleNote(noteEvent: CustomEvent, section: SongSection) {
        let { index, note } = noteEvent.detail;
        console.log("toggle", index, note);
        if (section.notes[note].has(index)) {
            section.notes[note].delete(index);
        } else {
            section.notes[note].add(index);
        }
        layout = layout;
    }
</script>

<div id="notes-wrapper">
    <div id="row-labels">
        {#each ["lc", "lt", "ll", "lb", "rc", "rt", "rr", "rb"] as note}
            <div class="note-label">{note}</div>
        {/each}
    </div>
    <div id="notes" bind:this={notesDiv}>
        {#each layout.sections as section}
            {#each ["lc", "lt", "ll", "lb", "rc", "rt", "rr", "rb"] as note}
                <Row
                    {note}
                    {section}
                    {notesPerBeat}
                    {noteWidth}
                    on:note={(event) => {
                        toggleNote(event, section);
                    }}
                ></Row>
            {/each}
        {/each}
        <div id="playhead" style:left={playheadPosition + "px"}></div>
    </div>
</div>

<style>
    #notes-wrapper {
        display: flex;
    }
    .note-label {
        height: 20px;
    }
    #notes {
        overflow-x: scroll;
        position: relative;
        /* border: 1px solid gray;
                border-bottom: none;
                border-right: none; */
    }
    #playhead {
        background-color: red;
        width: 2px;
        height: 100%;
        position: absolute;
        top: 0;
    }
</style>
