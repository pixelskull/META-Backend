; ModuleID = 'hello.ll'
source_filename = "hello.ll"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-ios10.0"

%Vs5Int32 = type <{ i32 }>
%Sp = type <{ i8* }>
%struct._SwiftEmptyArrayStorage = type { %struct.HeapObject, %struct._SwiftArrayBodyStorage }
%struct.HeapObject = type { %struct.HeapMetadata*, %struct.StrongRefCount, %struct.WeakRefCount }
%struct.HeapMetadata = type opaque
%struct.StrongRefCount = type { i32 }
%struct.WeakRefCount = type { i32 }
%struct._SwiftArrayBodyStorage = type { i64, i64 }
%swift.type = type { i64 }
%swift.protocol = type { i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i32, i32, i16, i16, i32 }
%swift.bridge = type opaque
%Any = type { [24 x i8], %swift.type* }
%SS = type <{ %Vs11_StringCore }>
%Vs11_StringCore = type <{ %GSqSv_, %Su, %GSqPs9AnyObject__ }>
%GSqSv_ = type <{ [8 x i8] }>
%Su = type <{ i64 }>
%GSqPs9AnyObject__ = type <{ [8 x i8] }>

@_TZvOs11CommandLine5_argcVs5Int32 = external global %Vs5Int32, align 4
@globalinit_33_FD9A49A256BEB6AF7C48013347ADC3BA_token4 = external global i64, align 8
@_TZvOs11CommandLine11_unsafeArgvGSpGSqGSpVs4Int8___ = external global %Sp, align 8
@_swiftEmptyArrayStorage = external global %struct._SwiftEmptyArrayStorage, align 8
@_TMLP_ = linkonce_odr hidden global %swift.type* null, align 8
@_swift_getExistentialTypeMetadata = external global %swift.type* (i64, %swift.protocol**)*
@_TMSS = external global %swift.type, align 8
@0 = private unnamed_addr constant [13 x i8] c"Hello World!\00"
@__swift_reflection_version = linkonce_odr hidden constant i16 1
@llvm.used = appending global [1 x i8*] [i8* bitcast (i16* @__swift_reflection_version to i8*)], section "llvm.metadata", align 8

define i32 @main(i32, i8**) #0 {
entry:
  %2 = bitcast i8** %1 to i8*
  store i32 %0, i32* getelementptr inbounds (%Vs5Int32, %Vs5Int32* @_TZvOs11CommandLine5_argcVs5Int32, i32 0, i32 0), align 4
  %3 = load i64, i64* @globalinit_33_FD9A49A256BEB6AF7C48013347ADC3BA_token4, align 8
  %4 = icmp eq i64 %3, -1
  br i1 %4, label %once_done, label %once_not_done

once_not_done:                                    ; preds = %entry
  call void @swift_once(i64* @globalinit_33_FD9A49A256BEB6AF7C48013347ADC3BA_token4, i8* bitcast (void ()* @globalinit_33_FD9A49A256BEB6AF7C48013347ADC3BA_func4 to i8*))
  br label %once_done

once_done:                                        ; preds = %once_not_done, %entry
  %5 = load i64, i64* @globalinit_33_FD9A49A256BEB6AF7C48013347ADC3BA_token4, align 8
  %6 = icmp eq i64 %5, -1
  call void @llvm.assume(i1 %6)
  store i8* %2, i8** getelementptr inbounds (%Sp, %Sp* @_TZvOs11CommandLine11_unsafeArgvGSpGSqGSpVs4Int8___, i32 0, i32 0), align 8
  %7 = call %swift.type* @_TMaP_() #7
  %8 = call { %swift.bridge*, i8* } @_TFs27_allocateUninitializedArrayurFBwTGSax_Bp_(i64 1, %swift.type* %7)
  %9 = extractvalue { %swift.bridge*, i8* } %8, 0
  %10 = extractvalue { %swift.bridge*, i8* } %8, 1
  %11 = bitcast i8* %10 to %Any*
  %12 = getelementptr inbounds %Any, %Any* %11, i32 0, i32 1
  store %swift.type* @_TMSS, %swift.type** %12, align 8
  %13 = getelementptr inbounds %Any, %Any* %11, i32 0, i32 0
  %object = bitcast [24 x i8]* %13 to %SS*
  %14 = call { i64, i64, i64 } @_TFSSCfT21_builtinStringLiteralBp17utf8CodeUnitCountBw7isASCIIBi1__SS(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @0, i64 0, i64 0), i64 12, i1 true)
  %15 = extractvalue { i64, i64, i64 } %14, 0
  %16 = extractvalue { i64, i64, i64 } %14, 1
  %17 = extractvalue { i64, i64, i64 } %14, 2
  %object._core = getelementptr inbounds %SS, %SS* %object, i32 0, i32 0
  %object._core._baseAddress = getelementptr inbounds %Vs11_StringCore, %Vs11_StringCore* %object._core, i32 0, i32 0
  %18 = bitcast %GSqSv_* %object._core._baseAddress to i64*
  store i64 %15, i64* %18, align 8
  %object._core._countAndFlags = getelementptr inbounds %Vs11_StringCore, %Vs11_StringCore* %object._core, i32 0, i32 1
  %object._core._countAndFlags._value = getelementptr inbounds %Su, %Su* %object._core._countAndFlags, i32 0, i32 0
  store i64 %16, i64* %object._core._countAndFlags._value, align 8
  %object._core._owner = getelementptr inbounds %Vs11_StringCore, %Vs11_StringCore* %object._core, i32 0, i32 2
  %19 = bitcast %GSqPs9AnyObject__* %object._core._owner to i64*
  store i64 %17, i64* %19, align 8
  %20 = call { i64, i64, i64 } @_TIFs5printFTGSaP__9separatorSS10terminatorSS_T_A0_()
  %21 = extractvalue { i64, i64, i64 } %20, 0
  %22 = extractvalue { i64, i64, i64 } %20, 1
  %23 = extractvalue { i64, i64, i64 } %20, 2
  %24 = call { i64, i64, i64 } @_TIFs5printFTGSaP__9separatorSS10terminatorSS_T_A1_()
  %25 = extractvalue { i64, i64, i64 } %24, 0
  %26 = extractvalue { i64, i64, i64 } %24, 1
  %27 = extractvalue { i64, i64, i64 } %24, 2
  call void @_TFs5printFTGSaP__9separatorSS10terminatorSS_T_(%swift.bridge* %9, i64 %21, i64 %22, i64 %23, i64 %25, i64 %26, i64 %27)
  ret i32 0
}

declare void @globalinit_33_FD9A49A256BEB6AF7C48013347ADC3BA_func4() #0

declare void @swift_once(i64*, i8*)

; Function Attrs: nounwind
declare void @llvm.assume(i1) #1

; Function Attrs: noinline
declare void @_TFs5printFTGSaP__9separatorSS10terminatorSS_T_(%swift.bridge*, i64, i64, i64, i64, i64, i64) #2

declare { %swift.bridge*, i8* } @_TFs27_allocateUninitializedArrayurFBwTGSax_Bp_(i64, %swift.type*) #0

; Function Attrs: nounwind readnone
define linkonce_odr hidden %swift.type* @_TMaP_() #3 {
entry:
  %protocols = alloca [0 x %swift.protocol*], align 8
  %0 = load %swift.type*, %swift.type** @_TMLP_, align 8
  %1 = icmp eq %swift.type* %0, null
  br i1 %1, label %cacheIsNull, label %cont

cacheIsNull:                                      ; preds = %entry
  %2 = bitcast [0 x %swift.protocol*]* %protocols to i8*
  call void @llvm.lifetime.start(i64 0, i8* %2)
  %3 = bitcast [0 x %swift.protocol*]* %protocols to %swift.protocol**
  %4 = call %swift.type* @rt_swift_getExistentialTypeMetadata(i64 0, %swift.protocol** %3) #1
  %5 = bitcast %swift.protocol** %3 to i8*
  call void @llvm.lifetime.end(i64 0, i8* %5)
  store atomic %swift.type* %4, %swift.type** @_TMLP_ release, align 8
  br label %cont

cont:                                             ; preds = %cacheIsNull, %entry
  %6 = phi %swift.type* [ %0, %entry ], [ %4, %cacheIsNull ]
  ret %swift.type* %6
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start(i64, i8* nocapture) #4

; Function Attrs: noinline nounwind
define linkonce_odr hidden %swift.type* @rt_swift_getExistentialTypeMetadata(i64, %swift.protocol**) #5 {
entry:
  %load = load %swift.type* (i64, %swift.protocol**)*, %swift.type* (i64, %swift.protocol**)** @_swift_getExistentialTypeMetadata
  %2 = tail call %swift.type* %load(i64 %0, %swift.protocol** %1)
  ret %swift.type* %2
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end(i64, i8* nocapture) #4

; Function Attrs: readonly
declare { i64, i64, i64 } @_TFSSCfT21_builtinStringLiteralBp17utf8CodeUnitCountBw7isASCIIBi1__SS(i8*, i64, i1) #6

; Function Attrs: noinline
declare { i64, i64, i64 } @_TIFs5printFTGSaP__9separatorSS10terminatorSS_T_A0_() #2

; Function Attrs: noinline
declare { i64, i64, i64 } @_TIFs5printFTGSaP__9separatorSS10terminatorSS_T_A1_() #2

attributes #0 = { "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "target-cpu"="cyclone" "target-features"="+neon,+crypto,+zcz,+zcm" }
attributes #1 = { nounwind }
attributes #2 = { noinline "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "target-cpu"="cyclone" "target-features"="+neon,+crypto,+zcz,+zcm" }
attributes #3 = { nounwind readnone "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "target-cpu"="cyclone" "target-features"="+neon,+crypto,+zcz,+zcm" }
attributes #4 = { argmemonly nounwind }
attributes #5 = { noinline nounwind }
attributes #6 = { readonly "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "target-cpu"="cyclone" "target-features"="+neon,+crypto,+zcz,+zcm" }
attributes #7 = { nounwind readnone }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !9, !10}

!0 = !{i32 1, !"Objective-C Version", i32 2}
!1 = !{i32 1, !"Objective-C Image Info Version", i32 0}
!2 = !{i32 1, !"Objective-C Image Info Section", !"__DATA, __objc_imageinfo, regular, no_dead_strip"}
!3 = !{i32 4, !"Objective-C Garbage Collection", i32 1024}
!4 = !{i32 1, !"Objective-C Class Properties", i32 64}
!5 = !{i32 6, !"Linker Options", !6}
!6 = !{!7, !8}
!7 = !{!"-lswiftCore"}
!8 = !{!"-lobjc"}
!9 = !{i32 1, !"PIC Level", i32 2}
!10 = !{i32 1, !"Swift Version", i32 4}
