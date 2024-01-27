import JSZip from "jszip";
import JSZipUtils from "jszip-utils";

import FileSaver from "file-saver";
export async function exportSong(song: SongLayout, soundFile: string): Promise<void> {
    if (!song || !soundFile) return;
    let songToExport: any = structuredClone(song);
    for (let i: number = 0; i < songToExport.sections.length; i++) {
        for (let note in songToExport.sections[i].notes) {
            songToExport.sections[i].notes[note] = Array.from(songToExport.sections[i].notes[note]);
        }
    }

    let zip = new JSZip();
    zip.file("data.json", JSON.stringify(songToExport));
    let data = await getBinaryContent(soundFile);
    zip.file("music.mp3", data);
    let content = await zip.generateAsync({ type: "blob" });
    FileSaver.saveAs(content, song.name + ".booty");
}

export async function importSong(file: File): Promise<{data: SongLayout, music: string}> {
    if (!file.name.endsWith(".booty")) {
        alert("This ain't no booty file!");
        throw "This ain't no booty file!";
    }
    let zipData = getBinaryContent(URL.createObjectURL(file))
    let newZip = await JSZip.loadAsync(zipData);
    let rawdata = await newZip.file("data.json")?.async("string");
    let rawmusic = await newZip.file("music.mp3")?.async("blob");
    if(!rawdata || !rawmusic) throw "Couldn't read elements of booty file."
    let data: SongLayout = JSON.parse(rawdata);
    for(let section of data.sections){
        for (let note in section.notes) {
            section.notes[note] = new Set(section.notes[note]);
        }
    }
    let music = URL.createObjectURL(rawmusic);
    return {data, music};
}

async function getBinaryContent(path: string): Promise<any> {
    return new Promise((resolve, reject) => {
        JSZipUtils.getBinaryContent(path, (err, data) => {
            if (err) {
                reject(err);
                return;
            }
            resolve(data);
        })
    });
}