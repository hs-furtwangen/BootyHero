<script lang="ts">
    import { createEventDispatcher } from "svelte";

    export let note: string;
    export let section: SongSection;
    export let notesPerBeat: number = 8;
    export let noteWidth: number = 10;

    $: duration = section.end - section.start;
    $: noteDuration = ((1 / section.bpm) * 60) / notesPerBeat;
    $: notesAmount = Math.floor(duration / noteDuration);

    // $: console.log({ duration, noteDuration, notesAmount });

    const dispatch = createEventDispatcher();
    let selectedNotes = structuredClone(section.notes[note]);

    function toggleNote(element: Event) {
        let target = <HTMLDivElement>element.target;
        let i = target.dataset.index;
        if (i === undefined) return;
        let index = parseInt(i);
        let time = noteDuration * index + section.start;
        dispatch("note", { index, time, note });
        if(selectedNotes.has(index)){
            selectedNotes.delete(index);
        } else {
            selectedNotes.add(index);
        }
        selectedNotes = selectedNotes;
    }
</script>

<div class="different-notes" id={note}>
    {#each { length: notesAmount } as xxxxx, index}
        <div
            class="one-note"
            class:beat={index % notesPerBeat == 0}
            class:active={selectedNotes.has(index)}
            data-index={index}
            style:width={noteWidth + "px"}
            on:click={toggleNote}
        ></div>
    {/each}
</div>

<style>
    .one-note {
        border: 1px solid gray;
        border-left: none;
        border-top: none;
        height: 20px;
        box-sizing: border-box;
    }

    .different-notes {
        display: flex;
        overflow-x: visible;
        flex-direction: row;
        width: fit-content;
        position: relative;
    }

    .one-note.beat {
        background-color: lightblue;
    }
    .one-note.active {
        background-color: green;
    }

    .note-label-wrapper{
        position: absolute;
        width: 100%;
        top:0;
        left: 0;
    }
    .note-label {
        position: sticky;
        top: 0;
        left: 0;
    }
</style>
