//
//  ViewController.swift
//  Vigenere
//
//  Created by Vitor Demenighi on 15/04/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    let main: Main = Main()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func touchedButton(_ sender: Any) {
        let keySize = main.discoverKeySize(originalText: textView.text)
        let result = main.discoveryKeyValue(keySize: keySize, text: textView.text)
        
        print(result)
    }
}

class Main {
    
    func discoverKeySize(originalText: String) -> Int {
        var lettersFrequency: [String: Int] = [:]
        
        /// Verifica o indice de coincidencia de chaves de tamanhos de 0 á 100
        for keySize in 1...100 {
            
            /// Separa o texto de acordo com o tamanho da chave
            let splitedText = splitText(keySize: keySize, orignalText: originalText)
        
            var coincidenceIndexTotal: Double = 0.0
            
            /// Pega o indice de coincidencia de cada parte separada do texto
            for text in splitedText {
                lettersFrequency = getFrequency(text: text)
                let coincidenceIndex = getCoincidenceIndex(frequency: lettersFrequency)
                coincidenceIndexTotal += coincidenceIndex
            }
            
            /// Pega a média do ndice de coincidencia
            let coincidenceIndexAverage = coincidenceIndexTotal/Double(keySize)
            
            /// Verifica se o resultado está de acordo com o valor aceitável para lingua portuguesa
            if verifyResult(coincidenceIndexAverage) {
                return keySize
            }
        }
        
        return 0
    }
    
    func discoveryKeyValue(keySize: Int, text: String) -> String {
        var lettersFrequency: [String: Int] = [:]
        var keyCandidate_A = ""
        var keyCandidate_E = ""
        
        /// Letras mais frequentes na lingua portuguesa
        let A_value = alphabetValues["a"]!
        let E_value = alphabetValues["e"]!
        
        /// Separa o texto em colunas de acordo com o tamanho da chave
        let splitedText = splitText(keySize: keySize, orignalText: text)
        
        for text in splitedText {
            lettersFrequency = getFrequency(text: text)
            let mostFrenquentlyLetter = getLetter(lettersFrequency: lettersFrequency)
            
            /// Pega os dois cadidados principais a senha
            keyCandidate_A += getKeyCandidate(with: A_value, mostFrenquentlyLetter.0)
            keyCandidate_E += getKeyCandidate(with: E_value, mostFrenquentlyLetter.0)
        }

        return ""
    }
    
    // MARK: - Common Functions
    
    /// Retornar as combinações possiveis entre as duas chaves. Alterna entre os caracteres das posições (exemplo: troca a 1 letra da chave 1 pela 1 letra da chave 2 e assim por diante)
    #warning("IMPLEMENTAR")
    func getCombinations(candidateOne: String, candidateTwo: String) -> [String] {
        let keySize = candidateOne.count
        
        let size = Int(pow(Double(2), Double(keySize)))
        
        for _ in 0..<size {}
        
        return []
        
//        for (int i = 0; i < Math.pow(2, key_size); i++) {
//            String binary = Integer.toBinaryString(i);
//            while (binary.length() < key_size) {
//                String a = "0";
//                a += binary;
//                binary = a;
//            }
//
//            String new_key = "";
//            for (int j = 0; j < binary.length(); j++) {
//                if (binary.substring(j, j + 1).equals("0")) {
//                    new_key += key.substring(j, j + 1);
//
//                } else {
//                    new_key += key2.substring(j, j + 1);
//                }
//            }
//            keys.add(new_key);
//        }
    }
    
    /// Encontra a chave candidata de acordo com o valor da letra refência escolhida (A ou E) e a a letra mais frequente da coluna
    func getKeyCandidate(with letterValue: Int, _ mostFrenquentlyLetter: String) -> String {
        let mostFrenquentlyLetterValue = alphabetValues[mostFrenquentlyLetter]!
        let resultValueLetter = mostFrenquentlyLetterValue - letterValue
        return getLetter(with: resultValueLetter)
    }
    
    /// Retorna a letra de maior frequência no texto
    func getLetter(lettersFrequency: [String: Int]) -> (String, Int) {
        var result = ("", 0)
        for letter in lettersFrequency {
            if letter.value > result.1 {
                result.0 = letter.key
                result.1 = letter.value
            }
        }
        
        return result
    }
    
    /// Retorna a quantidade de vezes que a letra aparece no texto
    func getFrequency(text: String) -> [String: Int] {
        var resultDic: [String: Int] = [:]
    
        for character in text {
            if character != " " {
                let previousValue =  resultDic[String(character)] ?? 0
                resultDic[String(character)] = previousValue + 1
            }
        }
        
        return resultDic
    }
    
    func splitText(keySize: Int, orignalText: String) -> [String]  {
        var resultString: [String] = [String](repeating: "", count: keySize)
        let noSpacesText = orignalText.replacingOccurrences(of: " ", with: "")
        var count = 0
        
        for index in 0..<noSpacesText.count {
            resultString[count] += String(noSpacesText[index])
            
            if count == keySize - 1 {
                count = 0
            } else {
                count += 1
            }
        }
        
        return resultString
    }
    
    // MARK: - IC Functions
    
    func getCoincidenceIndex(frequency: [String: Int]) -> Double {
        var numbersFrequencySummation: Double = 0.0
        var amountOfLetters: Double = 0.0

        for letter in frequency {
            numbersFrequencySummation += Double(letter.value * (letter.value - 1))
            amountOfLetters += Double(letter.value)
        }

        if amountOfLetters == 0.0 {
            return 0.0
        } else {
            return numbersFrequencySummation / ( amountOfLetters * (amountOfLetters - 1))
        }
    }
    
    func verifyResult(_ coincidenceIndex: Double) -> Bool {
        let coincidenceIndexPortuguese = 0.072723
        
        return (coincidenceIndex > (coincidenceIndexPortuguese - 0.01) && coincidenceIndex < (coincidenceIndexPortuguese + 0.01))
    }
    
    // MARK: - Alphabet
    
    var alphabetValues = ["a":0,
                          "b":1,
                          "c":2,
                          "d":3,
                          "e":4,
                          "f":5,
                          "g":6,
                          "h":7,
                          "i":8,
                          "j":9,
                          "k":10,
                          "l":11,
                          "m":12,
                          "n":13,
                          "o":14,
                          "p":15,
                          "q":16,
                          "r":17,
                          "s":18,
                          "t":19,
                          "u":20,
                          "v":21,
                          "w":22,
                          "x":23,
                          "y":24,
                          "z":25]
    
    /// Retorna a letra do alfabeto de acordo com o número passado por parâmetro
    func getLetter(with number: Int) -> String {
        for letter in alphabetValues where letter.value == number {
            return letter.key
        }
        return ""
    }
}

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}
