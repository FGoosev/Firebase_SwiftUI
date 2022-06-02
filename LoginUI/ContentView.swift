//
//  ContentView.swift
//  LoginUI
//
//  Created by Ian Solomein on 15.08.2020.
//  Copyright © 2020 Ian Solomein. All rights reserved.
//



import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseStorage

struct ContentView: View {
    
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    
    var body: some View {
        
        VStack{
            
            if status{
                
                Home()
            }
            else{
                
                SignIn()
            }
            
        }.animation(.spring())
            .onAppear {
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChange"), object: nil, queue: .main) { (_) in
                    
                    let status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                    self.status = status
                }
        }
        
    }
}

struct Home : View {
    
    @State private var showingPersonalArea = false
    @State private var showingPasswordEdit = false
    
    var body : some View{
        
        VStack{
            
            Text("Home").foregroundColor(.black).frame(width: UIScreen.main.bounds.width - 120).padding()
            Button(action: {
                self.showingPersonalArea.toggle()
            }){
                Text("Personal Area").foregroundColor(.white).frame(width: UIScreen.main.bounds.width - 120).padding()
            }.sheet(isPresented: $showingPersonalArea){
                PersonalArea()
            }.background(Color("color"))
                .clipShape(Capsule())
                .padding(.top, 45)
            
            Button(action: {
                self.showingPasswordEdit.toggle()
            }){
                Text("Edit password").foregroundColor(.white).frame(width: UIScreen.main.bounds.width - 120).padding()
            }.sheet(isPresented: $showingPasswordEdit){
                editPassword()
            }.background(Color("color"))
                .clipShape(Capsule())
                .padding(.top, 45)
            
            Button(action: {
                UserDefaults.standard.set(false, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                
            }) {
                
                Text("Logout").foregroundColor(.white).frame(width: UIScreen.main.bounds.width - 120).padding()
            }.background(Color("color"))
                .clipShape(Capsule())
                .padding(.top, 45)
            
        }
    }
}
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}

struct PersonalArea : View{
    @State var image = UIImage()
    @State private var showSheet = false
    @State var name = ""
    @State var surname = ""
    @State var bithdate = ""
    @State private var showingPersonalAreaEdit = false
    
        
    var body : some View{
        VStack{
            HStack{
                Image(uiImage: self.image)
                        .resizable()
                        .cornerRadius(50)
                        .padding(.all, 4)
                        .frame(width: 100, height: 100)
                        .background(Color.black.opacity(0.2))
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .padding(8)
                Text("Change photo")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.262745098, green: 0.0862745098, blue: 0.8588235294, alpha: 1)), Color(#colorLiteral(red: 0.5647058824, green: 0.462745098, blue: 0.9058823529, alpha: 1))]), startPoint: .top, endPoint: .bottom))
                        .cornerRadius(16)
                        .foregroundColor(.white)
                        .onTapGesture {
                                       showSheet = true
                                     }
                
            }.sheet(isPresented: $showSheet) {
                // Pick an image from the photo library:
                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                

                //  If you wish to take a photo from camera instead:
                // ImagePicker(sourceType: .camera, selectedImage: self.$image)
            }
            
            
            Text(name).fontWeight(.heavy).font(.largeTitle).padding([.top,.bottom], 20)
            Text(surname).fontWeight(.heavy).font(.largeTitle).padding([.top,.bottom], 20)
            Text(bithdate).fontWeight(.heavy).font(.largeTitle).padding([.top,.bottom], 20)
        }.onAppear(){
            
            
            guard let gotName = UserDefaults.standard.value(forKey: "Name")
                else {return}
            self.name = gotName as! String
            
            guard let gotSurname = UserDefaults.standard.value(forKey: "Surname")
                else {return}
            self.surname = gotSurname as! String
            
            guard let gotDate = UserDefaults.standard.value(forKey: "BithDate")
                else {return}
            self.bithdate = gotDate as! String
        }
        Button(action: {
            self.showingPersonalAreaEdit.toggle()
        }){
            Text("Personal Area Edit").foregroundColor(.white).frame(width: UIScreen.main.bounds.width - 120).padding()
        }.sheet(isPresented: $showingPersonalAreaEdit){
            PersonalAreaEdit()
        }.background(Color("color"))
            .clipShape(Capsule())
            .padding(.top, 45)
    }
}

struct PersonalAreaEdit : View{
    @State var name = ""
    @State var surname = ""
    @State var email = ""
    @State var avatar = ""
    @State var bithDate = ""
    var body : some View{
        VStack{
            VStack{
                Text("Name").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                HStack{
                    TextField("Enter your name", text: $name)
                }
                Divider()
            }.padding(.bottom, 15)
            
            VStack{
                Text("Surname").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                HStack{
                    TextField("Enter your surname", text: $surname)
                }
                Divider()
            }.padding(.bottom, 15)
            
            VStack{
                Text("bithDate").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                HStack{
                    TextField("Enter your bithDate", text: $bithDate)
                }
                Divider()
            }.padding(.bottom, 15)
            Button(action: {
                UserDefaults.standard.set(self.name, forKey: "Name")
                UserDefaults.standard.set(self.surname, forKey: "Surname")
                UserDefaults.standard.set(self.bithDate, forKey: "BithDate")
            }){
                Text("Save").foregroundColor(.white).frame(width: UIScreen.main.bounds.width - 120).padding()
            }.background(Color("color"))
                .clipShape(Capsule())
                .padding(.top, 45)
        }
        
    }
}

struct editPassword : View{
    @State var pass = ""
    @State var showingHome = false
    var body : some View{
        VStack{
            Spacer()
            Text("Edit Password")
            Spacer()
            HStack{
                SecureField("Enter new password", text: $pass)
            }.padding(45)

            Button(action: {
                Auth.auth().currentUser?.updatePassword(to: self.pass)
            }) {
                
                Text("Save").foregroundColor(.white).frame(width: UIScreen.main.bounds.width - 120).padding()
                
                
            }.background(Color("color"))
                .clipShape(Capsule())
                .padding(.top, 45)
            Spacer()
        }
    }
}

struct SignIn : View {
    
    @State var user = ""
    @State var pass = ""
    @State var message = ""
    @State var alert = false
    @State var show = false
    
    var body : some View{
        VStack {
            VStack{
                Text("Sign In").fontWeight(.heavy).font(.largeTitle).padding([.top,.bottom], 20)
                
                VStack(alignment: .leading){
                    
                    VStack(alignment: .leading){
                        
                        Text("Username").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                        
                        HStack{
                            
                            TextField("Enter Your Username", text: $user)
                            
                            if user != ""{
                                
                                Image("check").foregroundColor(Color.init(.label))
                            }
                            
                        }
                        
                        Divider()
                        
                    }.padding(.bottom, 15)
                    
                    VStack(alignment: .leading){
                        
                        Text("Password").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                        
                        SecureField("Enter Your Password", text: $pass)
                        
                        Divider()
                    }
                    
                }.padding(.horizontal, 6)
                
                Button(action: {
                    
                    signInWithEmail(email: self.user, password: self.pass) { (verified, status) in
                        
                        if !verified {
                            
                            self.message = status
                            self.alert.toggle()
                        }
                        else{
                            
                            UserDefaults.standard.set(true, forKey: "status")
                            NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                        }
                    }
                    
                }) {
                    
                    Text("Sign In").foregroundColor(.white).frame(width: UIScreen.main.bounds.width - 120).padding()
                    
                    
                }.background(Color("color"))
                    .clipShape(Capsule())
                    .padding(.top, 45)
                
            }.padding()
                .alert(isPresented: $alert) {
                    
                    Alert(title: Text("Error"), message: Text(self.message), dismissButton: .default(Text("Ok")))
            }
            VStack{
                
                Text("(or)").foregroundColor(Color.gray.opacity(0.5)).padding(.top,30)
                
                
                HStack(spacing: 8){
                    
                    Text("Don't Have An Account ?").foregroundColor(Color.gray.opacity(0.5))
                    
                    Button(action: {
                        
                        self.show.toggle()
                        
                    }) {
                        
                        Text("Sign Up")
                        
                    }.foregroundColor(.blue)
                    
                }.padding(.top, 25)
                
            }.sheet(isPresented: $show) {
                
                SignUp(show: self.$show)
            }
        }
    }
}

struct SignUp : View {
    
    @State var user = ""
    @State var pass = ""
    @State var message = ""
    @State var alert = false
    @Binding var show : Bool
    
    var body : some View{
        
        VStack{
            Text("Sign Up").fontWeight(.heavy).font(.largeTitle).padding([.top,.bottom], 20)
            
            VStack(alignment: .leading){
                
                VStack(alignment: .leading){
                    Text("Username").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                    
                    HStack{
                        
                        TextField("Enter Your Username", text: $user)
                        
                        if user != ""{
                            
                            Image("check").foregroundColor(Color.init(.label))
                        }
                        
                    }
                    
                    Divider()
                    
                }.padding(.bottom, 15)
                
                VStack(alignment: .leading){
                    
                    Text("Password").font(.headline).fontWeight(.light).foregroundColor(Color.init(.label).opacity(0.75))
                    
                    SecureField("Enter Your Password", text: $pass)
                    
                    Divider()
                }
                
            }.padding(.horizontal, 6)
            
            Button(action: {
                
                signUpWithEmail(email: self.user, password: self.pass) { (verified, status) in
                    
                    if !verified{
                        
                        self.message = status
                        self.alert.toggle()
                        
                    }
                    else{
                        
                        UserDefaults.standard.set(true, forKey: "status")
                        
                        self.show.toggle()
                        
                        NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                    }
                }
                
            }) {
                
                Text("Sign Up").foregroundColor(.white).frame(width: UIScreen.main.bounds.width - 120).padding()
                
                
            }.background(Color("color"))
                .clipShape(Capsule())
                .padding(.top, 45)
            
        }.padding()
            .alert(isPresented: $alert) {
                
                Alert(title: Text("Error"), message: Text(self.message), dismissButton: .default(Text("Ok")))
        }
    }
}


func signInWithEmail(email: String,password : String,completion: @escaping (Bool,String)->Void){
    
    Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
        
        if err != nil{
            
            completion(false,(err?.localizedDescription)!)
            return
        }
        
        completion(true,(res?.user.email)!)
    }
}

func signUpWithEmail(email: String,password : String,completion: @escaping (Bool,String)->Void){
    
    Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
        
        if err != nil{
            
            completion(false,(err?.localizedDescription)!)
            return
        }
        
        completion(true,(res?.user.email)!)
    }
}


func upload(currentUserId: String, photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void){
    let ref = Storage.storage().reference().child("avatars").child(currentUserId)
    guard let imageData = PersonalArea().image.jpegData(compressionQuality: 0.4) else{ return}
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    ref.putData(imageData, metadata: metadata){ (metadata, error) in
        guard let _ = metadata else {
            completion(.failure(error!))
            return
        }
        ref.downloadURL{ (url, error) in
            guard let url = url else{
                completion(.failure(error!))
                return
            }
            completion(.success(url))
        }
    }
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
