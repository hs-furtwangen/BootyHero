/**
 * describes the file layout for the layout file of a song.
 * all numbers are in seconds.
 * */

interface SongLayout {
    /** Sections of a song, in case there are different bpms to it */
    sections: SongSection[],
    /** Time before the first note is supposed to start */
    delay: number,
    notes: SongNotes,
    name: string,
    author: string,
}

interface SongSection {
    start: number,
    end: number,
    bpm: number,
}

interface SongNotes {
    //** Left Center - main Buttcheek */
    lc: number[],
    //** Left Top*/
    lt: number[],
    //** Left Left*/
    ll: number[],
    //** Left Bottom*/
    lb: number[],
    //** Right Center - main Buttcheek */
    rc: number[],
    //** Right Top*/
    rt: number[],
    //** Right Right*/
    rr: number[],
    //** Right Bottom*/
    rb: number[],
}