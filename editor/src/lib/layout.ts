/**
 * describes the file layout for the layout file of a song.
 * all numbers are in seconds.
 * */

interface SongLayout {
    /** Sections of a song, in case there are different bpms to it */
    sections: SongSection[],
    /** Time before the first note is supposed to start */
    delay: number,
    name: string,
    author: string,
}

interface SongSection {
    start: number,
    end: number,
    bpm: number,
    notes: SongNotes,
}

interface SongNotes {
    [id: string]: Set<number>;
    //** Left Center - main Buttcheek */
    lc: Set<number>,
    //** Left Top*/
    lt: Set<number>,
    //** Left Left*/
    ll: Set<number>,
    //** Left Bottom*/
    lb: Set<number>,
    //** Right Center - main Buttcheek */
    rc: Set<number>,
    //** Right Top*/
    rt: Set<number>,
    //** Right Right*/
    rr: Set<number>,
    //** Right Bottom*/
    rb: Set<number>,
}