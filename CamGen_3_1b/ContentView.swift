//
//  ContentView.swift
//  CamGen_3_1b_1  (CamGen31b_1 branch)
//
//  Created by David Dippold on 2/16/25.
//

import SwiftUI
import Foundation

struct CamGen31bView: View {
    // State variables for the index of selected parameters
    @State private var scaleIndex = 0
    @State private var tonicIndex = 0
    @State private var modeIndex = 0
    @State private var progSelIndex = 0
    
    @State private var p_cdeg = Array(repeating: Array(repeating: Array(repeating: 0, count: 3), count: 8), count: 10)
    let rows = 10
    let cols = 8
    @State private var mp_array = Array(repeating: Array(repeating: "", count: 3), count: 10)
   @State private var pc = [Int](repeating: 0, count: 8)

    @State private var resultParam: String = ""
    @State private var resultPC: String = ""  //[Int] = []
    @State private var resultNotes: String = ""
    @State private var resultPF: String = ""
    @State private var resultProg: String = ""
    @State private var resultMel: String = ""
    @State private var resultExtMel: String = ""
    
    // State variables used in MelMidi
    @State private var mDur = Array(repeating: "", count: 25)
    @State private var melNte = Array(repeating: "", count: 25)
    @State private var crNt = Array(repeating: Array(repeating: "", count: 3), count: 25)
    @State private var mNcnt = 0
    @State private var mBtRem = 0
    
    // Options for the pickers
    let scaleTypes = ["Major/Minor", "Ukrainian", "Harmonic", "Flamenco", "Persian", "Acoustic", "Gypsy", "Enigmatic", "Neapolitan"]
    let tonics = ["A", "Bb", "B", "C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#"]
    let modes = ["Ionian", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Aeolian", "Locrian"]
    let progSel = ["1","2","3","4","5","6","7","8","9","10"]
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Camgen")
                .font(.system(size: 36, weight: .bold))
                .padding()
            
            // Wrap the HStack in a rounded rectangle border
            HStack(alignment: .center, spacing: 20) {
                // Scale Type Picker
                Picker("Scale", selection: $scaleIndex) {
                    ForEach(0 ..< scaleTypes.count, id: \.self) { index in
                        Text(scaleTypes[index]).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 200) // Sets the picker width to
                
                // Tonic Picker
                Picker("Tonic", selection: $tonicIndex) {
                    ForEach(0 ..< tonics.count, id: \.self) { index in
                        Text(tonics[index]).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 200) // Sets the picker width to
                
                // Mode Picker
                Picker("Mode", selection: $modeIndex) {
                    ForEach(0 ..< modes.count, id: \.self) { index in
                        Text(modes[index]).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 200) // Sets the picker width to
            }
            .padding() // Add padding inside the border
            .background(
                RoundedRectangle(cornerRadius: 10) // Rounded corners
                    .stroke(Color.gray, lineWidth: 3) // Border color and width
            )
            
            // Buttons
            Button("Find Chords")
            {
                let results = fdChrds(scaleIndex: scaleIndex, tonicIndex: tonicIndex, modeIndex: modeIndex)
                resultParam = results.0
                resultPC = results.1
                resultNotes = results.2
                resultPF = results.3
                resultProg = results.4
            }
            .font(.system(size: 15)) // Set the font size
            .padding(10.0)
            .background(
                RoundedRectangle(cornerRadius: 10) // Rounded corners
                    .stroke(Color.gray, lineWidth: 3) // Border color and width
            )
            // Progression Picker
            Picker("ProgNum", selection: $progSelIndex) {
                ForEach(0 ..< progSel.count, id: \.self) { index in
                    Text(progSel[index]).tag(index)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 150) // Sets the picker width to 200 points
            
            // Horizontal stacking of Mel & ExtMel buttons
            HStack(alignment: .center, spacing: 20) {
                Button("Melody          ")
                {
                    let results = expandMel(progSelIndex: progSelIndex)
                    resultExtMel = results.0
                    mNcnt = results.1
                    mBtRem = results.2
                    melNte = results.3
                    crNt = results.4
                    mDur = results.5
                }
                .font(.system(size: 15)) // Set the font size
                .padding(10.0)
                .background(
                    RoundedRectangle(cornerRadius: 10) // Roundedcorners
                        .stroke(Color.gray, lineWidth: 3) // Border color and width
                )
                Button("Melody Midi") {
                    MelodyMidi4(mNcnt: mNcnt, mBtRem: mBtRem, ChrNte: crNt, MelNte: melNte, mDur: mDur)
                }
                .font(.system(size: 15)) // Set the font size
                .padding(10.0)
                .background(
                    RoundedRectangle(cornerRadius: 10) // Roundedcorners
                        .stroke(Color.gray, lineWidth: 3) // Border color and width
                )
           }
            
            Divider()
            
            // Results Frame (only shows after button press)
            ScrollView { // Wrap the VStack in a ScrollView
                VStack(alignment: .leading, spacing: 10) { // Fixed spacing between elements
                    // Display the parameters
                    Text(resultParam)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15))
                    
                    // Display the pc's
                    Text(resultPC)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15))
                    
                    // Display the scale notes
                    Text(resultNotes)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15))
                    
                    // Display the PF chords
                    if !resultPF.isEmpty {
                        let parts = resultPF.components(separatedBy: "\n")
                        if parts.count > 1 {
                            Text(parts[1])
                                .bold()
                                .font(.system(size: 15))
                            Text(parts[2...].joined(separator: "\n"))
                                .font(.system(size: 15))
                        } else {
                            Text(resultPF)
                                .font(.system(size: 15))
                        }
                    }
                    
                    // Display the progressions
                    if !resultProg.isEmpty {
                        let parts = resultProg.components(separatedBy: "\n")
                        if parts.count > 1 {
                            Text(parts[1])
                                .bold()
                                .font(.system(size: 15))
                            Text(parts[2...].joined(separator: "\n"))
                                .font(.system(size: 15))
                        } else {
                            Text(resultProg)
                                .font(.system(size: 15))
                        }
                    }
                    
                    // Display the extended melody
                    if !resultExtMel.isEmpty {
                        let parts = resultExtMel.components(separatedBy: "\n")
                        if parts.count > 1 {
                            Text(parts[1])
                                .bold()
                                .font(.system(size: 15))
                            Text(parts[2...].joined(separator: "\n"))
                                .font(.system(size: 15))
                        } else {
                            Text(resultExtMel)
                                .font(.system(size: 15))
                        }
                    }
           
                }
                .padding()
                .frame(width: 500, alignment: .leading) // Ensure the frame aligns content to the leading edge
            }
            .frame(minWidth: 600, minHeight: 600) // Set the frame for the ScrollView
            .background(Color(.windowBackgroundColor)) // Use NSColor for macOS compatibility
        }
    }
    //MARK
    // Function to check the seventh
    func chkSeventh(pc: [Int], pcdum: Int) -> Int {
        var fflg = 0
        for i in 0..<7 {
            if pcdum == pc[i] {
                fflg = 1
            }
        }
        return fflg
    }
    
    //MARK
    // Function to find the integer rank
    func findRank(dum: Int, chordClass: [Int]) -> Int {
        var searchFlag = 0
        var i = 0
        var pos = 999
        while searchFlag == 0 && i < 12 {
            if dum == chordClass[i] {
                searchFlag = 1
                pos = i
            } else {
                i += 1
            }
        }
        return pos
    }
    
    //MARK
    // Function to find the string rank
    func findRank2(MelNte: String, KeyNts: [String]) -> Int {
        var searchFlag = 0
        var i = 0
        var pos = 999
        while searchFlag == 0 && i < 12 {
            if MelNte == KeyNts[i] {
                searchFlag = 1
                pos = i
            } else {
                i += 1
            }
        }
        return pos
    }
    
    
    //MARK
    // Main function equivalent to FdChrds_Click
    func fdChrds(scaleIndex: Int, tonicIndex: Int, modeIndex: Int)  -> (String, String ,String, String, String){
        let S_ID = scaleIndex
        // let T_ID = tonicIndex
        let M_ID = modeIndex
        
        let cdum = "   "
        var chrdarray = [String](repeating: "", count: 35)
        let chrdclss = [1331, 1001, 845, 833, 935, 663, 627, 665, 483, 575, 435, 279]
        var chrdescrp = [String](repeating: "", count: 35)
        var chrdpcs = [[Int]](repeating: [Int](repeating: 0, count: 3), count: 12)
        var chrdpc7 = [[Int]](repeating: [Int](repeating: 0, count: 4), count: 12)
        var chrtype = [String](repeating: "", count: 35)
        var cList = ["", "", "", "", "", "", "", "", "", "", "", ""] //[String](repeating: "", count: 12)
        var cList7 = ["", "", "", "", "", "", "", "", "", "", "", ""]  //[String](repeating: "", count: 12)
        let cnotes = ["A", "Bb", "B", "C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#"]
        var croot = [Int](repeating: 0, count: 40)
        let dumpc = [9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8]
        var pc = [Int](repeating: 0, count: 7)
        var dum = 0
        var fflg = 0
        var id = [Double](repeating: 0.0, count: 40)
        var int1 = 0, Int2 = 0, Int3 = 0
        var intv = [Int](repeating: 0, count: 7)
        var jdum = 0
        var jnum = ""
        var kmax = 0
        let modename = ["Ionian", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Aeolian", "Locrian"]
        var npf = 0, npf7 = 0
        var pcdum = 0
        var pos = 0
        let prm = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41]
        var progarray = [String](repeating:"", count: 10)
        var progseq = [Int](repeating:0, count: 8)
        var ratio = [String](repeating: "", count: 35)
        var rw = [[String]](repeating: [String](repeating: "", count: 6), count: 12)
        let nscale = ["Maj/Min", "Ukrain", "Harm", "Flam", "Pers", "Acous", "Gypsy", "Enig", "Neap"]
        let sintvs = [
            [2, 2, 1, 2, 2, 2, 1],
            [1, 2, 1, 2, 2, 1, 3],
            [1, 2, 1, 3, 1, 2, 2],
            [1, 1, 3, 1, 2, 1, 3],
            [1, 1, 2, 3, 1, 1, 3],
            [1, 2, 1, 2, 2, 2, 2],
            [1, 1, 2, 2, 2, 1, 3],
            [1, 1, 1, 3, 2, 2, 2],
            [1, 1, 2, 2, 2, 2, 2]
        ]
        
        var triplet = [[Int]](repeating: [Int](repeating: 0, count: 3), count: 40)
        var typedum = ""
        var wline1 = ""
        let ascalntes = 7
        // Read the scale notes and adjust for mode
        intv = Array(sintvs[S_ID][0..<ascalntes])
        
        pc = [Int](repeating: 0, count: 8)
        var doct = [Int](repeating: 0, count: 8)
        var letscale = [String](repeating: "", count: 8)
        var pl_scale = [String](repeating: "", count: 8)
        
        pc[0] = tonicIndex
        doct[0] = 3
        letscale[0] = cnotes[pc[0]]
        pl_scale[0] = cnotes[pc[0]] + String(doct[0])
        
        for j in 1..<7 {
            jdum = (j - 1 + M_ID) % 7
            pc[j] = (pc[j - 1] + intv[jdum]) % 12
            letscale[j] = cnotes[pc[j]]
        }
        
        for j in 0..<7 {
            if j > 0 {
                if dumpc[pc[j]] > dumpc[pc[j - 1]] {
                    doct[j] = doct[j - 1]
                } else {
                    doct[j] = doct[j - 1] + 1
                }
            }
            letscale[j] = cnotes[pc[j]]
            pl_scale[j] = cnotes[pc[j]] + String(doct[j])
        }
        
        // Repeat 1st note as 8th note of scale
        pc[7] = pc[0]
        letscale[7] = letscale[0]
        doct[7] = doct[0] + 1
        pl_scale[7] = letscale[7] + String(doct[7])
        
        // New code starts here
        var k = -1
        triplet = [[Int]](repeating: [Int](repeating: 0, count: 3), count: 35)
        for j in 0..<ascalntes {
            for n in (j + 1)..<ascalntes {
                for m in (n + 1)..<ascalntes {
                    k += 1
                    triplet[k][0] = pc[j]
                    triplet[k][1] = pc[n]
                    triplet[k][2] = pc[m]
                    
                    // Put pcs in order, min first
                    if pc[j] < pc[n] {
                        if pc[j] < pc[m] {
                            triplet[k][0] = pc[j]
                            if pc[n] < pc[m] {
                                triplet[k][1] = pc[n]
                                triplet[k][2] = pc[m]
                            } else {
                                triplet[k][1] = pc[m]
                                triplet[k][2] = pc[n]
                            }
                        } else {
                            triplet[k][0] = pc[m]
                            triplet[k][1] = pc[j]
                            triplet[k][2] = pc[n]
                        }
                    } else {
                        if pc[j] < pc[m] {
                            triplet[k][0] = pc[n]
                            triplet[k][1] = pc[j]
                            triplet[k][2] = pc[m]
                        } else {
                            if pc[n] < pc[m] {
                                triplet[k][0] = pc[n]
                                triplet[k][1] = pc[m]
                                triplet[k][2] = pc[j]
                            } else {
                                triplet[k][0] = pc[m]
                                triplet[k][1] = pc[n]
                                triplet[k][2] = pc[j]
                            }
                        }
                    }
                    
                    int1 = abs(triplet[k][1] - triplet[k][0])
                    Int2 = abs(triplet[k][2] - triplet[k][1])
                    Int3 = 12 - (int1 + Int2)
                    ratio[k] = "\(int1) : \(Int2) : \(Int3)"
                    id[k] = Double(prm[int1 - 1] * prm[Int2 - 1] * prm[Int3 - 1])
                    
                    if id[k] == 1001 {
                        if int1 == 4 && Int2 == 3 {
                            chrtype[k] = cnotes[triplet[k][0]] + "maj"
                            croot[k] = triplet[k][0]
                        } else if int1 == 3 && Int2 == 4 {
                            chrtype[k] = cnotes[triplet[k][0]] + "min"
                            croot[k] = triplet[k][0]
                        } else if int1 == 5 && Int2 == 3 {
                            chrtype[k] = cnotes[triplet[k][1]] + "min"
                            croot[k] = triplet[k][1]
                        } else if int1 == 5 && Int2 == 4 {
                            chrtype[k] = cnotes[triplet[k][1]] + "maj"
                            croot[k] = triplet[k][1]
                        } else if Int2 == 5 && Int3 == 3 {
                            chrtype[k] = cnotes[triplet[k][1]] + "min"
                            croot[k] = triplet[k][1]
                        } else if Int2 == 5 && Int3 == 4 {
                            chrtype[k] = cnotes[triplet[k][2]] + "maj"
                            croot[k] = triplet[k][2]
                        }
                    } else if id[k] == 845 {
                        if int1 == 5 && Int2 == 5 {
                            chrtype[k] = cnotes[triplet[k][2]] + "sus2"
                        } else if int1 == 5 && Int2 == 2 {
                            chrtype[k] = cnotes[triplet[k][1]] + "sus2"
                        } else if int1 == 2 && Int2 == 5 {
                            chrtype[k] = cnotes[triplet[k][0]] + "sus2"
                        }
                    }
                }   //close m loop
            }       //close n loop
        }           //close j loop
        
        kmax = k + 1
        var m = 7
        npf = -1
        npf7 = -1
        wline1 = "Chords\n"
        wline1 += "#  Ratio     CN1   CN2   CN3   PF  M/m\n"
        for j in 0..<kmax {
            if j < 11 {
                jnum = "\(j)  "
            } else {
                jnum = "\(j) "
            }
            dum = Int(id[j])
            pos = findRank(dum: dum, chordClass:chrdclss)
            if pos < 12 {
                m += 1
                if dum == 1001 || dum == 845 {
                    wline1 += "\(jnum)\(cdum) \(ratio[j])    \(cnotes[triplet[j][0]])      \(cnotes[triplet[j][1]])      \(cnotes[triplet[j][2]])"
                } else {
                    wline1 += "\(jnum)\(cdum) \(ratio[j])    \(cnotes[triplet[j][0]])      \(cnotes[triplet[j][1]])      \(cnotes[triplet[j][2]])    *    *    "
                }
                if dum == 1001 {
                    npf += 1
                    cList[npf] = chrtype[j]
                    wline1 += "   P5    \(chrtype[j])"
                    for jjj in 0..<3 {
                        chrdescrp[npf] = chrdescrp[npf] +                 cnotes[triplet[j][jjj]]
                        
                        if jjj == 2 {
                            rw[npf][jjj] = cnotes[triplet[j][jjj]]
                        } else {
                            rw[npf][jjj] = "\(cnotes[triplet[j][jjj]]) "  //, "
                        }
                        chrdpcs[npf][jjj] = triplet[j][jjj]
                    }
                    rw[npf][3] = "\(chrtype[j]) "  //, "
                    chrdarray[npf] = rw[npf][3]
                    
                    typedum = String(chrtype[j].suffix(3))
                    if typedum == "maj" {
                        pcdum = (croot[j] + 11) % 12
                        fflg = chkSeventh(pc: pc, pcdum: pcdum)
                        if fflg == 1 {
                            rw[npf][4] = "\(chrtype[j])7 "  //, "
                            chrdarray[npf] = rw[npf][4]
                            npf7 += 1
                            cList7[npf7] = "\(chrtype[j])7 "
                            for jjj in 0..<3 {
                                chrdpc7[npf7][jjj] = triplet[j][jjj]
                            }
                            chrdpc7[npf7][3] = pcdum
                        }
                        pcdum = (croot[j] + 10) % 12
                        fflg = chkSeventh(pc: pc, pcdum: pcdum)
                        if fflg == 1 {
                            rw[npf][5] = "\(cnotes[croot[j]])7 "
                            chrdarray[npf] = rw[npf][5]
                            npf7 += 1
                            cList7[npf7] = "\(cnotes[croot[j]])7 "
                            for jjj in 0..<3 {
                                chrdpc7[npf7][jjj] = triplet[j][jjj]
                            }
                            chrdpc7[npf7][3] = pcdum
                        }
                    } else if typedum == "min" {
                        pcdum = (croot[j] + 10) % 12
                        fflg = chkSeventh(pc: pc, pcdum: pcdum)
                        if fflg == 1 {
                            rw[npf][4] = "\(cnotes[croot[j]])m7 "
                            chrdarray[npf] = rw[npf][4]
                            
                            npf7 += 1
                            cList7[npf7] = "\(cnotes[croot[j]])m7 "
                            for jjj in 0..<3 {
                                chrdpc7[npf7][jjj] = triplet[j][jjj]
                            }
                            chrdpc7[npf7][3] = pcdum
                        }
                    }
                } else if dum == 845 {
                    wline1 += "     *       \(chrtype[j])"
                    npf += 1
                    cList[npf] = chrtype[j]
                    rw[npf][0] = "\(cnotes[triplet[j][0]]), "
                    rw[npf][1] = "\(cnotes[triplet[j][1]]), "
                    rw[npf][2] = "\(cnotes[triplet[j][2]])"
                    for jjj in 0..<3 {
                        chrdpcs[npf][jjj] = triplet[j][jjj]
                        chrdescrp[npf] = chrdescrp[npf] + cnotes[triplet[j][jjj]]
                    }
                    rw[npf][3] = "\(chrtype[j]) "
                    chrdarray[npf] = rw[npf][3]
                }
            }
        }    //close j loop
        
        var wline2 = [String](repeating: "", count: npf + 1)
        for n in 0..<(npf + 1) {
            wline2[n] +=  rw[n][3]
            wline2[n] += rw[n][4]
            wline2[n] += rw[n][5]
            wline2[n] += "   : ("
            for j in 0..<3 {
                wline2[n] += rw[n][j]
            }
            wline2[n] += ")"
        }
        
        // Form the progressions
        let progLth = 8
        var fdum = ""
        var dumprog = ""
        print ("starting piSequence loop")
        for n in 0..<10 {
            dumprog = ""
            progseq = PiSequence(progLth: progLth, npf: npf)    //proglth, npf chords
            for i in 0..<8 {
                if i < 7 {
                    fdum = ","
                }
                else {
                    fdum = ""
                }
                dumprog = dumprog + chrdarray[progseq[i]]  + fdum
                progarray[n] = dumprog
                for j in 0..<3 {
                    p_cdeg[n][i][j] = chrdpcs[progseq[i]][j]
                }
            }
            mp_array[n] = progarray
        }
        
        // Break down the output into smaller parts
        let output0 =  "PARAMETERS:    \(nscale[scaleIndex])    \(cnotes[tonicIndex])    \(modename[modeIndex])"
        let o1:[Int] = ([pc[0], pc[1], pc[2], pc[3], pc[4], pc[5], pc[6]])
            
        // Convert the integer array to a string array and join them with commas
        let o1String = o1.map { String($0) }.joined(separator: ", ")
        // Append the label to the output
        let output1 = "PITCH CLASS: \(o1String)"
           
        let output2 = "NOTES: \(letscale[0])  \(letscale[1]) \(letscale[2]) \(letscale[3])  \(letscale[4]) \(letscale[5])  \(letscale[6])\n"
        
       var output3 = "\nPerfect Fifth Chords\n"
        for j in 0..<(npf + 1) {
            let leadP = "("
            let lagP = ")"
            chrdescrp[j] = leadP + chrdescrp[j] + lagP
            let jStr = String(j+1)  // Convert j to a string
            output3 += "\(jStr): \(chrdarray[j]) \(chrdescrp[j])\n"
        }
        var output4 = "\nProgressions\n"
        // Loop through number of progressions
        for j in 0..<(10) {
            let jStr = String(j+1)  // Convert j to a string
            output4 += "\(jStr): \(progarray[j])\n"
        }
       return (output0, output1, output2, output3, output4)
    }
        
    //MARK
    // Pi function to provide a random sequence of 8 pi digits used to form the chord //progressions
    func PiSequence(progLth: Int, npf: Int) -> [Int]
        {
         var piSeq1 = [Int](repeating: 0, count: 8)
         var piSeq2 = [Int](repeating: 0, count: 8)
         var progseq = [Int](repeating: 0,  count: 8)
            // *******************************
            // The first 500 digits of pi
            // *******************************
            let PiDigits = [1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8, 9, 7, 9, 3, 2, 3, 8, 4, 6, 2, 6, 4, 3, 3, 8, 3, 2, 7, 9,
                            5, 0, 2, 8, 8, 4, 1, 9, 7, 1, 6, 9, 3, 9, 9, 3, 7, 5, 1, 0,5, 8, 2, 0, 9, 7, 4, 9, 4, 4, 5, 9, 2, 3, 0, 7, 8, 1, 6, 4,
                            0, 6, 2, 8, 6, 2, 0, 8, 9, 9, 8, 6, 2, 8, 0, 3, 4, 8, 2, 5, 3, 4, 2, 1, 1, 7, 0, 6, 7, 9, 8, 2, 1, 4, 8, 0, 8, 6, 5, 1,
                            3, 2, 8, 2, 3, 0, 6, 6, 4, 7, 0, 9, 3, 8, 4, 4, 6, 0, 9, 5, 5, 0, 5, 8, 2, 2, 3, 1, 7, 2, 5, 3, 5, 9, 4, 0, 8, 1, 2, 8,
                            4, 8, 1, 1, 1, 7, 4, 5, 0, 2, 8, 4, 1, 0, 2, 7, 0, 1, 9, 3, 8, 5, 2, 1, 1, 0, 5, 5, 5, 9, 6, 4, 4, 6, 2, 2, 9, 4, 8, 9,
                            5, 4, 9, 3, 0, 3, 8, 1, 9, 6, 4, 4, 2, 8, 8, 1, 0, 9, 7, 5, 6, 6, 5, 9, 3, 3, 4, 4, 6, 1, 2, 8, 4, 7, 5, 6, 4, 8, 2, 3,
                            3, 7, 8, 6, 7, 8, 3, 1, 6, 5, 2, 7, 1, 2, 0, 1, 9, 0, 9, 1, 4, 5, 6, 4, 8, 5, 6, 6, 9, 2, 3, 4, 6, 0, 3, 4, 8, 6, 1, 0,
                            4, 5, 4, 3, 2, 6, 6, 4, 8, 2, 1, 3, 3, 9, 3, 6, 0, 7, 2, 6, 0, 2, 4, 9, 1, 4, 1, 2, 7, 3, 7, 2, 4, 5, 8, 7, 0, 0, 6, 6,
                            0, 6, 3, 1, 5, 5, 8, 8, 1, 7, 4, 8, 8, 1, 5, 2, 0, 9, 2, 0, 9, 6, 2, 8, 2, 9, 2, 5, 4, 0, 9, 1, 7, 1, 5, 3, 6, 4, 3, 6,
                            7, 8, 9, 2, 5, 9, 0, 3, 6, 0, 0, 1, 1, 3, 3, 0, 5, 3, 0, 5, 4, 8, 8, 2, 0, 4, 6, 6, 5, 2, 1, 3, 8, 4, 1, 4, 6, 9, 5, 1,
                            9, 4, 1, 5, 1, 1, 6, 0, 9, 4, 3, 3, 0, 5, 7, 2, 7, 0, 3, 6, 5, 7, 5, 9, 5, 9, 1, 9, 5, 3, 0, 9, 2, 1, 8, 6, 1, 1, 7, 3,
                            8, 1, 9, 3, 2, 6, 1, 1, 7, 9, 3, 1, 0, 5, 1, 1, 8, 5, 4, 8, 0, 7, 4, 4, 6, 2, 3, 7, 9, 9, 6, 2, 7, 4, 9, 5, 6, 7, 3, 5,
                            1, 8, 8, 5, 7, 5, 2, 7, 2, 4, 8, 9, 1, 2, 2, 7, 9, 3, 8, 1, 8, 3, 0, 1, 1, 9, 4, 9, 1, 2, 9, 8, 3, 3, 6, 7, 3, 3, 6, 2,
                            4, 4, 0, 6, 5, 6, 6, 4, 3, 0, 8, 6, 0, 2, 1, 3, 9, 4, 9, 4, 6, 3, 9, 5, 2, 2, 4, 7, 3, 7, 1, 9, 0, 7, 0, 2, 1, 7, 9, 8]
            
            // *************************************************
            // Randomize the starting point
            // and find the data starting and ending rows
            // *************************************************
            let strpos1 = Int.random(in: 1..<(500-progLth))
            let strpos2 = Int.random(in: 1..<(500-progLth))
            //*********************************
            // Find the starting row and
            // Read two rows of pi digits
            // *********************************
            for j in 0..<progLth {
                piSeq1[j] = PiDigits[strpos1 + j]
                piSeq2[j] = PiDigits[strpos2 + j]
            }
            // *************************************************
            // Find the sequence of Pi digits equal to Number of Chords
            //# *************************************************
            if npf <= 10 {
                for k in 0..<progLth {
                    progseq[k] = piSeq1[k]%npf
                    //         i = i + 1
                }
             }
            else if npf > 10 {
                for k in 0..<progLth {
                    progseq[k] = (piSeq1[k] + piSeq2[k])%npf
                }
            }
            return progseq
        }
        
        
        //MARK
        // Based on scale, tonic, mode, the 7 scale notes, the perfect fifth chords, and 1 of the 10 random chord progressions, 8 chords in length. The progression length(8) and the number of progressions(10) are currently hard coded. Given a progression, the code finds a simple melody and transition notes along with note durations.
        // ************************************************
        // Public Sub sPath(ByRef ChrDeg, FstNte, NChord, Dist, DNotes, ByRef SimMel)
        // ************************************************
        func sPath(ChrDeg: [[Int]], FstNte: Int, NChord: Int, DNotes: [String]) -> [String] {
            print ("Starting spath")
        //    var Chord = [String](repeating: "", count: 7)
            let rows = 15, cols = 3
            var Dtot = [[Double]](repeating: [Double](repeating: 0.0, count: cols), count: rows)
            var DumD = 0.0
            var FCNte = [Int](repeating: -1, count: 3)
            var Note = [[Int]](repeating: [Int](repeating: 0, count: 3), count: 15)
            var P = [Int](repeating: -1, count: 50)
            var Path = [[Int]](repeating: [Int](repeating: -1, count: 3), count: 50)
            
            // Find the notes in the first chord
            for j in 0..<3 {
                FCNte[j] = ChrDeg[0][j]
                Dtot[0][j] = 0.0
            }
            // Find notes on subsequent chords
            for k in 1..<NChord {
                for j in 0..<3 {
                    Note[k][j] = ChrDeg[k][j]
                }
            }
            // Find the chord - spanning melody with minimum distance.
            // Do not choose a melody note whose immediate predecessor
            // was the same note.
            for j in 0..<3 {
                Note[0][j] = FCNte[FstNte]
            }
            for i in 1..<NChord {
                for j in 0..<3 {
                    var minV = 9999.0
                    for k in 0..<3 {
                        let rn = Double.random(in: 0..<1)
                        let rDist = 0.05 * rn
                        if abs(Note[i][j] - Note[i-1][k]) >= 2 {
                            DumD = Dtot[i-1][k] + Double(abs(Note[i][j] - Note[i-1][k])) + rDist
                            if DumD < minV {
                                minV = DumD
                                Path[i][j] = k
                            }
                        } else {
                             DumD = 9999.0
                        }
                    }
                    Dtot[i][j] = minV
                }
            }
            // Write results
            var MinP = 9999.0
            var jmin = 0
            for j in 0..<3 {
                if Dtot[NChord - 1][j] < MinP {
                    MinP = Dtot[NChord - 1][j]
                    jmin = j
                }
            }
            P[NChord - 1] = jmin
            for k in stride(from: NChord - 2, through: 0, by: -1) {
                P[k] = Path[k + 1][P[k + 1]]
            }
            var SimMel = [String](repeating: "", count: 8)
            for j in 0..<NChord {
                if j == 0 {
                    SimMel[j] = DNotes[FCNte[FstNte]]
                } else {
                    SimMel[j] = DNotes[Note[j][P[j]]]
                }
            }
            return SimMel
        }
        
        //MARK
        // ************************************************
        //Public Sub angle2(CNotes, CandiN, NCandN, ByRef Radian)
        // ************************************************
        func angle2(CNotes: [Int], CandiN: [Int], NCandN: Int) -> Double {
            var CosTrm = [Double](repeating: 0.0, count: 6)
            var SinTrm = [Double](repeating: 0.0, count: 6)
            var FPSpCh = [Double](repeating: 0.0, count: 6)
            var FPSpCa = [Double](repeating: 0.0, count: 6)
            let PiVal = 3.14159
            // Calculate the Fourier Power Spectrum for the measure's Chord Notes
            var LChord = 0.0
            for k in 0..<6 {
                CosTrm[k] = 0.0
                SinTrm[k] = 0.0
            }
            for i in 0..<3 {
                for k in 0..<6 {
                    let rk = Double(k)
                    CosTrm[k] += cos(2 * PiVal * Double(CNotes[i]) * (rk + 1) / 12)
                    SinTrm[k] += sin(2 * PiVal * Double(CNotes[i]) * (rk + 1) / 12)
                }
            }
            for k in 0..<6 {
                let CTrmSq = CosTrm[k] * CosTrm[k]
                let STrmSq = SinTrm[k] * SinTrm[k]
                FPSpCh[k] = CTrmSq + STrmSq
                LChord += FPSpCh[k] * FPSpCh[k]
            }
            LChord = sqrt(LChord)
            // Calculate the Fourier Power Spectrum for Candidate Notes
            var LCandi = 0.0
            for k in 0..<6 {
                CosTrm[k] = 0.0
                SinTrm[k] = 0.0
            }
            for i in 0..<NCandN {
                for k in 0..<6 {
                    let rk = Double(k)
                    CosTrm[k] += cos(2 * PiVal * Double(CandiN[i]) * (rk + 1) / 12)
                    SinTrm[k] += sin(2 * PiVal * Double(CandiN[i]) * (rk + 1) / 12)
                }
            }
            for k in 0..<6 {
                let CTrmSq = CosTrm[k] * CosTrm[k]
                let STrmSq = SinTrm[k] * SinTrm[k]
                FPSpCa[k] = CTrmSq + STrmSq
                LCandi += FPSpCa[k] * FPSpCa[k]
            }
            LCandi = sqrt(LCandi)
             // Find the Angle (radians) between Chord Spectrum and Candidate Spectrum
            var xyprd = 0.0
            for k in 0..<6 {
                xyprd += FPSpCh[k] * FPSpCa[k]
            }
            var CTheta = xyprd / (LChord * LCandi)
            if CTheta > 1.0 {
                CTheta = 1.0
            }
            if CTheta < -1.0 {
                CTheta = -1.0
            }
             let Radian = acos(CTheta)
            return Radian
        }
        
        //MARK
        // **************************
        //Melody DP function
        // **************************
        func MelDP(Nchord: Int, ChrDeg: [[Int]], DNotes: [String], NPClss: [Int], SimMel: [String]) -> [[Int]] {
            // Initialize certain variables
            var CaDum = [Int](repeating: -1, count: 6)
            var Candi = [Int](repeating: 999, count: 5)
            var ChdNte = [Int](repeating: -1, count: 3)
            var Dist = [Double](repeating: 0.0, count: 15)
            var KeyNts = [String](repeating: "", count: 12)
            var MaxP = [Int](repeating: 0, count: 15)
            var MaxPth = [Double](repeating: 9999.0, count: 15)
            var PthCnt = [Int](repeating: -1, count: 15)
            var Rank = [Int](repeating: 0, count: 15)
            var TranNt = [[Int]](repeating: [Int](repeating: 999, count: 3), count: 20)
            for i in 0..<Nchord {
                MaxP[i] = 0
                PthCnt[i] = -1
                for k in 0..<3 {
                    TranNt[i][k] = 999
                }
            }
            for i in 0..<12 {
                KeyNts[i] = DNotes[i]
            }
            // Read the Simple Melody
            for k in 0..<Nchord {
                let MelNte = SimMel[k]
                Rank[k] = findRank2(MelNte: MelNte, KeyNts: KeyNts)
            }
            // For one pair of measures at a time, find the number of tones/semitones from one melody note to next
            for k in 0..<(Nchord - 1) {
                MaxPth[k] = 9999.0
                for j in 0..<3 {
                    ChdNte[j] = NPClss[ChrDeg[k][j]]
                    CaDum[j] = NPClss[ChrDeg[k][j]]
                    CaDum[j + 3] = NPClss[ChrDeg[k + 1][j]]
                }
                let SemiTD = abs(Rank[k + 1] - Rank[k])
                let NSteps = SemiTD - 1
                 // Find the Candidate 1 - note transition from melody note in measure k to melody note in measure k+1
                if NSteps == 1 {
                    let MelNte = SimMel[k]
                    let MNNum = findRank2(MelNte: MelNte, KeyNts: KeyNts)
                    // 1st candidate is always the melody note in measure k
                    Candi[0] = NPClss[MNNum]
                    let NCandN = 2
                    for i in 0..<6 {
                        Candi[1] = CaDum[i]
                        let Radian = angle2(CNotes: ChdNte, CandiN:Candi, NCandN: NCandN)
                        Dist[k] = Radian
                        if Dist[k] < MaxPth[k] {
                            MaxPth[k] = Dist[k]
                            TranNt[k][0] = Candi[1]
                        }
                    }
                }
                // Subsequent Stages: one or two transition notes
                if NSteps == 2 {
                    let MelNte = SimMel[k]
                    let MNNum = findRank2(MelNte: MelNte, KeyNts: KeyNts)
                    Candi[0] = NPClss[MNNum]
                    let NCandN = 3
                    for i in 0..<6 {
                        Candi[1] = CaDum[i]
                        for j in (i + 1)..<6 {
                            Candi[2] = CaDum[j]
                            let Radian = angle2(CNotes: ChdNte, CandiN:Candi, NCandN: NCandN)
                            Dist[k] = Radian
                            if Dist[k] < MaxPth[k] {
                                MaxPth[k] = Dist[k]
                                TranNt[k][0] = Candi[1]
                                TranNt[k][1] = Candi[2]
                            }
                        }
                    }
                }
                // Three transition notes (quarter notes)
                if NSteps > 2 {
                    let MelNte = SimMel[k]
                    let MNNum = findRank2(MelNte: MelNte, KeyNts: KeyNts)
                    Candi[0] = NPClss[MNNum]
                    let NCandN = 4
                    for i in 0..<6 {
                        Candi[1] = CaDum[i]
                        for j in (i + 1)..<6 {
                            Candi[2] = CaDum[j]
                            for M in (j + 1)..<6 {
                                Candi[3] = CaDum[M]
                                let Radian = angle2(CNotes: ChdNte, CandiN: Candi, NCandN: NCandN)
                                Dist[k] = Radian
                                if Dist[k] < MaxPth[k] {
                                    MaxPth[k] = Dist[k]
                                    MaxP[k] = PthCnt[k]
                                    TranNt[k][0] = Candi[1]
                                    TranNt[k][1] = Candi[2]
                                    TranNt[k][2] = Candi[3]
                                }
                            }
                        }
                    }
                }
            }
            return TranNt
        }
        
        //MARK
        // Function to expand simple melody
        func expandMel(progSelIndex: Int) -> (String, Int, Int, [String], [[String]], [String]) {
            print ("Starting expand mel func", progSelIndex)
            var chrDeg = Array(repeating: Array(repeating: -1, count: 3), count: 8)
            let pID = progSelIndex
            for i in 0..<8 {
                for j in 0..<3 {
                    chrDeg[i][j] = p_cdeg[pID][i][j]
                }
            }
            var chrNte = Array(repeating: Array(repeating: "", count: 3), count: 25)
            var crNt = Array(repeating: Array(repeating: "", count: 3), count: 25)
            let dNotes = ["A", "Bb", "B", "C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#"]
            var melNte = Array(repeating: "", count: 25)
            let nChord = 8
            var mDur = Array(repeating: "", count: 25)
            var nDur = Array(repeating: "", count: 5)
            let npClss = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
            let octDum = 4
            var sklNte = Array(repeating: 999, count: 12)
            var skPC = Array(repeating: -1, count: 8)
            for j in 0..<7 {
                skPC[j] = pc[j]
            }
            var trNcnt = Array(repeating: -1, count: 25)
            for i in 0..<8 {
                for j in 0..<3 {
                    chrNte[i][j] = dNotes[chrDeg[i][j]]
                }
            }
        //    let octavB = octDum - 2
            // Randomize the melody's first chord note
            let rn = Double.random(in: 0..<1)
            let fstNte: Int
            if rn < 0.333 {
                fstNte = 0
            } else if rn < 0.666 {
                fstNte = 1
            } else {
                fstNte = 2
            }
      //      let method = 1 // Simple melody-1: SP; 2: DP
            // Identify the permissible note candidates in array sklNte(i)
            for i in 0..<7 {
                sklNte[skPC[i]] = 1
            }
            for k in 0..<nChord {
                for j in 0..<3 {
                    sklNte[chrDeg[k][j]] = 1
                }
            }
            print ("Begin simple mel")
            // Find and write the simple melody
            let simMel = sPath(ChrDeg: chrDeg, FstNte: fstNte, NChord: nChord, DNotes: dNotes)
            // Expand the simple melody to include transition notes
            let tranNt = MelDP(Nchord: nChord, ChrDeg: chrDeg, DNotes: dNotes, NPClss: npClss, SimMel: simMel)
            print ("Finish MelDP sub")
            // Write to file
            // NDur Data (WN:840; HN:820; QN+8:814; QN:810; 8N:4
            nDur[0] = "W"   // 840
            nDur[1] = "H"   // 820
            nDur[2] = "Q+E" // 814
            nDur[3] = "Q"   // 810
            nDur[4] = "E"   // 4
            var cnt = -1
            for k in 0..<nChord {
                cnt += 1
                melNte[cnt] = simMel[k] + String(octDum)
                crNt[cnt][0] = chrNte[k][0] + String(octDum-1)
                crNt[cnt][1] = chrNte[k][1] + String(octDum-1)
                crNt[cnt][2] = chrNte[k][2] + String(octDum-1)
                trNcnt[k] = 0
                for j in 0..<3 {
                   if tranNt[k][j] != 999 { // Not equal
                        trNcnt[k] += 1
                        var iflg = 0
                        var iii = 0
                        while iflg == 0 {
                            if tranNt[k][j] == npClss[iii] {
                                iflg = 1
                                let tNtDum = iii
                                cnt += 1
                                melNte[cnt] = dNotes[tNtDum] + String(octDum)
                                crNt[cnt][0] = chrNte[k][0] + String(octDum-1)
                                crNt[cnt][1] = chrNte[k][1] + String(octDum-1)
                                crNt[cnt][2] = chrNte[k][2] + String(octDum-1)
                            }else {
                                iii += 1
                            }
                        }   // closes while
                    }       // closes if
                }           // closes j loop
            }                // closes k loop
            var mNcnt = cnt
            // Write Melody Note Durations
            cnt = -1
            var mBtRem = 0
            for k in 0..<nChord {
                // Whole Note
                if trNcnt[k] == 0 {
                    cnt += 1
                    mDur[cnt] = nDur[0]
                    mBtRem += 7
                }
                // Half, Qtr+8th, 8th
                else if trNcnt[k] == 2 {
                    cnt += 1
                    mDur[cnt] = nDur[1]
                    mBtRem += 7
                    cnt += 1
                    mBtRem += 7
                    mDur[cnt] = nDur[2]
                    cnt += 1
                    mDur[cnt] = nDur[4]
                    mBtRem += 6
                } else {
                    let iii = Int(Double(trNcnt[k]))
                    for j in 0..<iii + 1 {
                        cnt += 1
                        mDur[cnt] = nDur[trNcnt[k]]
                        mBtRem += 7
                    }
                }
            }
            mNcnt = cnt + 1
            print ("mNcnt,melNte", mNcnt, melNte)
            // Write some output:
            var output5 = "\nMelody   Duration    Chord\n"
            for j in 0..<(mNcnt) {
                let jStr = String(j+1)  // Convert j to a string
                output5 += "\(jStr): \(melNte[j])         \(mDur[j])         \(crNt[j][0])/\(crNt[j][1])/\(crNt[j][2])\n"
            }
            let output6 = mNcnt
            let output7 = mBtRem
            let output8 = melNte
            let output9 = crNt
            let output10 = mDur
            
        return (output5, output6, output7, output8, output9, output10)
        }
    
    //MARK
    func getNextNote(_ h_lk_up: String) -> UInt8? {
        let s_notes = ["B5", "Bb5", "A#5", "A5", "Ab5", "G#5", "G5", "Gb5", "F#5", "F5", "E5", "Eb5", "D#5", "D5", "Db5", "C#5", "C5",
            "B4", "Bb4", "A#4", "A4", "Ab4", "G#4","G4","Gb4","F#4","F4","E4", "Eb4", "D#4", "D4", "Db4", "C#4", "C4", "B3", "Bb3", "A#3", "A3", "Ab3", "G#3", "G3", "Gb3", "F#3", "F3", "E3", "Eb3", "D#3", "D3",
                "Db3", "C#3", "C3"]
        
        let h_notes: [UInt8] = [0x53, 0x52, 0x52, 0x51, 0x50, 0x50, 0x4F, 0x4E, 0x4E, 0x4D, 0x4C, 0x4B, 0x4B, 0x4A, 0x49, 0x49,
                                0x48, 0x47, 0x46, 0x46, 0x45, 0x44, 0x44, 0x43, 0x42, 0x42, 0x41, 0x40, 0x3F, 0x3F, 0x3E, 0x3D,
                                0x3D, 0x3C, 0x3B, 0x3A, 0x3A, 0x39, 0x38, 0x38, 0x37, 0x36, 0x36, 0x35, 0x34, 0x33, 0x33, 0x32,
                                0x31, 0x31, 0x30]

        var h_flg = 0
        var i = 0
        var h_nte: UInt8? = nil

        // Find the corresponding note in the list
        while h_flg == 0 && i < s_notes.count {
            if h_lk_up.trimmingCharacters(in: .whitespaces) == s_notes[i].trimmingCharacters(in: .whitespaces) {
                h_flg = 1
                h_nte = h_notes[i]
            }
            i += 1
        }
    //    print("Converted \(h_lk_up) to \(String(describing: h_nte))")
        return h_nte
     }

    //MARK: Parse/Invert
    func parsInvert(_ oldNote: String, _ flg: Int) -> String {
        var CNote: [String]
        if flg == 1 {
            CNote = ["A4", "Bb4", "B4", "C4", "C#4", "D4", "Eb4", "E4", "F4", "F#4", "G4", "G#4"]
        } else {
            CNote = ["A3", "Bb3", "B3", "C3", "C#3", "D3", "Eb3", "E3", "F3", "F#3", "G3", "G#3"]
        }
        var fFlg = 0
        var i = 0
        var nRnk = -1
        // Find the rank of the old note
        while fFlg == 0 && i < CNote.count {
            if oldNote == CNote[i] {
                fFlg = 1
                nRnk = i
            } else {
                i += 1
            }
        }
        // Invert old note to get new note
        var newRnk = 12 - nRnk
        if newRnk == 12 {
            newRnk = 0
        }
        let newNote = CNote[newRnk]
        return newNote
    }
    

    //MARK: convert new notes to proper hex format
    func convertToHex(note: String, loc: String) -> UInt8  {
    //    print ("Starting convertToHex: note = ", note)
        var noteValue: UInt8?
        var hNote = String()
          if let hexValue = getNextNote(note) {
              hNote = String(format: "0x%02X", hexValue)
              if let value = UInt8(hNote.dropFirst(2), radix: 16) {
                  noteValue = value
              } else {
                  hNote = "hNote Unknown" // or handle the case where the note is not found
                  print ("hNote Unknown", loc)
              }
          } else {
              print ("Prob getting hexValue", loc)
          }
          return noteValue!
      }
    
/*    func convertToHex(note: String) -> UInt8  {
        print ("Starting convertToHex: note = ", note)
        var hNote = String()
        if let hexValue = getNextNote(note) {
            hNote = String(format: "0x%02X", hexValue)
        } else {
          hNote = "Unknown" // or handle the case where the note is not found
        }
        var noteValue: UInt8?
        if let value = UInt8(hNote.dropFirst(2), radix: 16) {
            noteValue = value
        } else {
            // Handle the error case appropriately
        }
        return noteValue!
    }
   */
    //MARK: Melody Midi
    func MelodyMidi4(mNcnt: Int, mBtRem: Int, ChrNte: [[String]], MelNte: [String], mDur: [String]) {
        // Dimension section
        print ("Starting Melody Midi")
        print ("Melody Notes: ", MelNte)
        let fName = "/Users/daviddippold/Library/Containers/DGD.CamGen-3-1b/Data/Documents/MelodyMidi_out.mid"
        let fileURL = URL(fileURLWithPath: fName)
        var fType = -1
        var mLData = [String](repeating: "", count: 100)
        var mIns = 1  // 1: piano; 2: guitar; 3: strings
       // var mNote = ""
        var mNote: String
        var nChar = -1
        var NoteOn = ""
        let nOn = 0x9
        var RstFLg = -1
        var spd = 1  // default: 128 beats per minute
        var Title = ""
        var Vol = ""
        
        // Read in the exp melody data from Debug sheet
        let numTracks = 2  // 1: melody only; 2: melody plus chords
        fType = 1
        let NChord = 8
        var chordNote = [[String]](repeating: [String](repeating: "", count: 3), count: 15)
        var crNt = [[String]](repeating: [String](repeating: "", count: 3), count: 20)
        for i in 0..<NChord {
            for j in 0..<3 {
                chordNote[i][j] = ChrNte[i][j]
            }
        }
        
        // Midi dimension section
        print ("Midi Dimension Section")
        let ticksPerBeat = 0x80
        let midiHeader: [UInt8] = [0x4D, 0x54, 0x68, 0x64, 0x0, 0x0, 0x0, 0x6]
        let SubFormatType: [UInt8] = [0x0, 0x1]  // Type-1 MIDI file (as opposed to Type-0)
        let Speed: [UInt8] = [0x0, 0x80]  // Default to 128 ticks per beat
        let TrackHeader: [UInt8] = [0x4D, 0x54, 0x72, 0x6B]
        let TemMM: [UInt8] = [0x0, 0xFF, 0x51, 0x3]  // Tempo message header
        let Temtt: [UInt8] = [0x5, 0x68, 0xD8]  // Tempo
        let footer: [UInt8] = [0xFF, 0x2F, 0x0]
        var mInstr: [UInt8] = [0x0, 0xC0, 0x1, 0x0]
        let cInstr: [UInt8] = [0x0, 0xC1, 0x2, 0x0]
        let CTrkHeader: [UInt8] = [0x0, 0xFF, 0x3, 0x6, 0x43, 0x68, 0x6F, 0x72, 0x64, 0x73]
        let MTrkHeader: [UInt8] = [0x0, 0xFF, 0x3, 0x6, 0x4D, 0x65, 0x6C, 0x6F, 0x64, 0x79]
        let trkSubHeader: [UInt8] = [0x0, 0xFF, 0x3, 0x6, 0x53, 0x63, 0x61, 0x6C, 0x65, 0x73]
        var fmNote: [UInt8] = []
        var cNote = [String](repeating: "", count: 3)
        var LcNote = [String](repeating: "", count: 3)
        var LmNote = ""
        var newNote = ""
        let MTrk = 1
        mIns = 1
        let MInst = 1
        let Lp = 2
        let NtCntM = mNcnt
        let mBRem: UInt32 = UInt32(4 * mBtRem + 25 + 7)  // MBtr*num loops + 25 ovhd + 7 is for last mel note
        var CbRem: UInt32 = UInt32(4 * (NChord * 19) + 18 + 19)  // Lp=#loops
        
        // Write Header and subformat type
        print ("Writing to file: \(fName)")
        if FileManager.default.fileExists(atPath: fName){
            print ("File Exists: \(fName)")
        }
       
        if let fileHandle = FileHandle(forWritingAtPath: fName) {
            fileHandle.write(Data(midiHeader))
            fileHandle.write(Data(SubFormatType))
            let numTracks = 2
            let byteTracks: [UInt8] = [UInt8((numTracks >> 8) & 0xFF), UInt8(numTracks & 0xFF)]
            fileHandle.write(Data(byteTracks))
            fileHandle.write(Data(Speed))
            
            // Begin track loop
            print ("Begin Track loop")
            for k in 0..<2 {
                if k == 0 {
                    fileHandle.write(Data(TrackHeader))
                    var mBRemBytes = withUnsafeBytes(of: mBRem.bigEndian, Array.init)
                    fileHandle.write(Data(mBRemBytes))
                    fileHandle.write(Data(TemMM))
                    fileHandle.write(Data(Temtt))
                    
                    // write 1st track header & instrument
                    fileHandle.write(Data(MTrkHeader))
                    if mIns == 2 {
                        mInstr[2] = 0x20
                    } else if mIns == 3 {
                        mInstr[2] = 0x27
                    }
                    fileHandle.write(Data(mInstr))
                    
                    print ("  // Add melody notes")
  
              //   First melody note
                    var noteValue: UInt8?
                    noteValue = convertToHex(note: MelNte[0], loc: "fM_ktrk0")
                    if mDur[0] == "E" {
                        fmNote = [0x90, noteValue!, 0x70, 0x40, noteValue!, 0x0, 0x0]
                    } else if mDur[0] == "Q" {
                        fmNote = [0x90, noteValue!, 0x70, 0x81, 0x0, noteValue!, 0x0, 0x0]
                    } else if mDur[0] == "Q+E" {
                        fmNote = [0x90, noteValue!, 0x70, 0x81, 0x40, noteValue!, 0x0, 0x0]
                    } else if mDur[0] == "H" {
                        fmNote = [0x90, noteValue!, 0x70, 0x82, 0x0, noteValue!, 0x0, 0x0]
                    } else if mDur[0] == "W" {
                        fmNote = [0x90, noteValue!, 0x70, 0x84, 0x0, noteValue!, 0x0, 0x0]
                    }
                    fileHandle.write(Data(fmNote))
                    print ("First mNote complete")
                    var LmNote: UInt8?
                    LmNote = noteValue!    //mNote This sets last mnote to first note


                    print ("Begin melody sLoop")
                    for sLoop in 0..<4 {
                        RstFLg = 2
                        let begJloop = sLoop == 0 ? 1 : 0
                        let endJloop = NtCntM
                        let incVal = 1
                        print ("Begin melody j loop", NtCntM, begJloop, endJloop)
                        for j in stride(from: begJloop, to: endJloop, by: incVal) {
                            if sLoop == 2 {
                                newNote = parsInvert(MelNte[j], 1)
                                noteValue = convertToHex(note: newNote, loc: "M_s2_kk_j")
                            } else {
                                noteValue = convertToHex(note: MelNte[j], loc: "M_s_kk_j")
                            }
                            let rn = Double.random(in: 0..<1)
                            if mDur[j] == "W" {
                                Vol = "70"
                            } else {
                                if rn > 0.1 || RstFLg > 0 {
                                    Vol = "70"
                                    RstFLg -= 1
                                } else {
                                    Vol = "0"
                                    RstFLg = 2
                                }
                            }
                            
                            var nMNote: [UInt8]
                            if mDur[j] == "E" {
                                nMNote = [noteValue!, UInt8(Vol)!, 0x40, noteValue!, 0x0, 0x0]
                            } else if mDur[j] == "Q" {
                                nMNote = [noteValue!, UInt8(Vol)!, 0x81, 0x0, noteValue!, 0x0, 0x0]
                            } else if mDur[j] == "Q+E" {
                                nMNote = [noteValue!, UInt8(Vol)!, 0x81, 0x40, noteValue!, 0x0, 0x0]
                            } else if mDur[j] == "H" {
                                nMNote = [noteValue!, UInt8(Vol)!, 0x82, 0x0, noteValue!, 0x0, 0x0]
                            } else if mDur[j] == "W" {
                                nMNote = [noteValue!, UInt8(Vol)!, 0x84, 0x0, noteValue!, 0x0, 0x0]
                            } else {
                                nMNote = []
                            }
                            fileHandle.write(Data(nMNote))
                        }
                    }
                    print ("Begin LstMNote")
                    let LstMNote: [UInt8] = [LmNote!, 0x70, 0x84, 0x0, LmNote!, 0x0, 0x0]
                    fileHandle.write(Data(LstMNote))
                    fileHandle.write(Data(footer))
                }
                print ("Begin chord write")
                
                if k == 1 {
                    var cNV0: UInt8?
                    var cNV1: UInt8?
                    var cNV2: UInt8?

                    fileHandle.write(Data(TrackHeader))
                   // CbRem = 4 * (NChord * 19) + 18 + 19
                    let CbRemBytes = withUnsafeBytes(of: CbRem.bigEndian, Array.init)
                    fileHandle.write(Data(CbRemBytes))
                    fileHandle.write(Data(CTrkHeader))
                    fileHandle.write(Data(cInstr))
                    print ("chordNote[0][0]: ",chordNote[0][0])
                    for j in 0..<3 {
                        if j == 0 {
                            cNV0 = convertToHex(note: chordNote[0][j], loc: "fC_j0")
                        } else if j == 1 {
                            cNV1 = convertToHex(note: chordNote[0][j], loc: "fC_j1")
                        } else {
                            cNV2 = convertToHex(note: chordNote[0][j], loc: "fC_j2")
                        }
                    }
                    let fCNote: [UInt8] = [0x91, cNV0!, 0x60, 0x0, cNV1!, 0x60, 0x0, cNV2!, 0x60, 0x84, 0x0, cNV0!, 0x0, 0x0, cNV1!, 0x0, 0x0, cNV2!, 0x0, 0x0]
                    fileHandle.write(Data(fCNote))
                    
                    var LcNote0: UInt8?
                    var LcNote1: UInt8?
                    var LcNote2: UInt8?
                    var nValue: UInt8?
                    var cNote0: UInt8?
                    var cNote1: UInt8?
                    var cNote2: UInt8?
                    LcNote0 = cNV0
                    LcNote1 = cNV1
                    LcNote2 = cNV2
                    print ("Begin chord sLoop")
                    for sLoop in 0..<4 {
                        let begKKloop = sLoop == 0 ? 1 : 0
                        let endKKloop = NChord
                        let incVal = 1
                        print ("Begin chord kk loop", NChord)
                        for kk in stride(from: begKKloop, to: endKKloop, by: incVal) {
                            print ("Begin chord j loop")
                            for j in 0..<3 {
                               if sLoop == 2 {
                                    newNote = parsInvert(chordNote[kk][j], 2)
                                    nValue = convertToHex(note: newNote, loc: "C_s2_kk_j")
                                } else {
                                    nValue = convertToHex(note: chordNote[kk][j],loc: "C_s_kk_j")
                                }
                                if j == 0 {
                                    cNote0 = nValue
                                } else if j == 1 {
                                    cNote1 = nValue
                                } else if j == 2 {
                                    cNote2 = nValue
                                }
                            }
                            let nCNote: [UInt8] = [cNote0!, 0x60, 0x0, cNote1!, 0x60, 0x0, cNote2!, 0x60, 0x84, 0x0, cNote0!, 0x0, 0x0, cNote1!, 0x0, 0x0, cNote2!, 0x0, 0x0]
                            fileHandle.write(Data(nCNote))
                        }
                    }
                    print ("Form last chord note")
                   let LstcNote: [UInt8] = [LcNote0!, 0x60, 0x0, LcNote1!, 0x60, 0x0, LcNote2!, 0x60, 0x84, 0x0, LcNote0!, 0x0, 0x0, LcNote1!, 0x0, 0x0, LcNote2!, 0x0, 0x0]
                    fileHandle.write(Data(LstcNote))
                    fileHandle.write(Data(footer))
                    print ("Data write complete")
                }
           }
        } else {
            print("Failed to open file for writing.")
        }
    }
}


// MARK:  End of main functions

struct CamGen31bView_Previews: PreviewProvider {
     static var previews: some View {
          CamGen31bView()
     }
}
